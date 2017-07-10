namespace eval qc {
    namespace export db_file_* file_upload plupload.html
}

proc qc::db_file_insert {args} {
    #| Insert a file into the file db table
    args $args -user_id ? -filename ? -mime_type ? -- file_path

    if { ![info exists user_id] } {
        set user_id [auth]
    }
    default filename [file tail $file_path]

    if { ! [info exists mime_type] } {
        set mime_type [ns_guesstype $filename]
    }
   
    set id [open $file_path r]
    fconfigure $id -translation binary
    set data [base64::encode [read $id]]
    close $id

    set file_id [db_seq file_id_seq]
    set qry {
	insert into file 
	(file_id,user_id,filename,data,mime_type)
	values 
	(:file_id,:user_id,:filename,decode(:data, 'base64'),:mime_type)
    }
    db_dml $qry
    return $file_id

}

proc qc::db_file_copy {file_id} {
    #| Make a copy of this file
    set new_file_id [db_seq file_id_seq]
    db_dml {
        insert into file 
        (file_id,user_id,filename,data,mime_type)
	select :new_file_id,user_id,filename,data,mime_type
        from file where file_id=:file_id
    }
    return $new_file_id
}

proc qc::db_file_export {args} {
    # Export a file in the db file table to a tmp local file
    args $args -tmp_file ? -- file_id

    default tmp_file /tmp/[uuid::uuid generate]
    db_1row {select filename, encode(data,'base64') as base64 from file where file_id=:file_id}
    set id [open $tmp_file w]
    fconfigure $id -translation binary
    puts $id [base64::decode $base64]
    close $id
    return $tmp_file
}

proc qc::plupload.html {name chunk chunks file} {
    # Deprecated
    return [db_file_upload $name $chunk $chunks $file]
}

proc qc::db_file_upload {name chunk chunks file {filename ""} {mime_type ""}} {
    #| Upload a file chunk, insert the completed file into the db when complete.
    if { $filename eq "" } {
        set filename $file
    }
    set flags [dict create -filename $filename]
    dict set flags -user_id [qc::auth]
    if { $mime_type ne "" } {
        dict set flags -mime_type $mime_type
    }
    set tmp_file [qc::file_upload $name $chunk $chunks $file]
    if { $tmp_file ne "" } {
        ::try {
            set file_id [qc::db_file_insert {*}$flags $tmp_file]
            if { [qc::file_is_valid_image $tmp_file] } {
                dict2vars [qc::image_file_info $tmp_file] width height
                db_dml {
                    insert into image
                    (file_id, width, height)
                    values
                    (:file_id, :width, :height)
                }
            }
        } finally {
            file delete $tmp_file
        }
        return $file_id
    } else {
        return ""
    }
}
