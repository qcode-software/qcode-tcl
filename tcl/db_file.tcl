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
        set mime_type [qc::mime_type_guess $filename]
    }
   
    set file_id [db_seq file_id_seq]
    set s3_location [qc::s3 uri [qc::param_get s3_file_bucket] $file_id]
    # upload file to amazon s3
    qc::s3 put $s3_location $file_path
    
    set qry {
	insert into file 
	(file_id,user_id,filename,mime_type,s3_location)
	values 
	(:file_id,:user_id,:filename,:mime_type,:s3_location)
    }
    db_dml $qry
    return $file_id

}

proc qc::db_file_copy {file_id} {
    #| Make a copy of this file
    set new_file_id [db_seq file_id_seq]
    db_dml {
        insert into file 
        (file_id,user_id,filename,data,mime_type,s3_location)
	select
        :new_file_id,
        user_id,
        filename,
        data,
        mime_type,
        s3_location
        from file
        where file_id=:file_id
    }
    return $new_file_id
}

proc qc::db_file_export {args} {
    # Export a file in the db file table to a tmp local file
    args $args -tmp_file ? -- file_id

    default tmp_file /tmp/[qc::uuid]
    db_1row {
        select
        filename,
        encode(data,'base64') as base64,
        s3_location
        from file
        where file_id=:file_id
    }

    if { $s3_location eq "" } {
        # file does not exists on amazon s3
        set id [open $tmp_file w]
        fconfigure $id -translation binary
        puts -nonewline $id [base64::decode $base64]
        close $id
    } else {
        # file exists on amazon s3
        qc::s3 get $s3_location $tmp_file
    }
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

proc qc::db_file_migrate_to_s3 {file_id} {
    set tmp_file [db_file_export $file_id]
    set s3_location [qc::s3 uri [qc::param_get s3_file_bucket] $file_id]
    qc::s3 put $s3_location $tmp_file
    
    set qry {
	update file
        set s3_location=:s3_location, data=NULL
        where file_id=:file_id
    }
    db_dml $qry
    
    return $s3_location
}

proc qc::db_file_delete {file_id} {
    #| Delete a file
    db_1row {
        select
        s3_location
        from file
        where
        file_id=:file_id
    }

    if { $s3_location ne "" } {
        qc::s3 delete $s3_location
    }
    db_dml {delete from file where file_id=:file_id}
}
