package provide qcode 1.8
namespace eval qc {}

proc qc::db_file_insert {args} {
    #| Insert a file into the file db table
    args $args -employee_id ? -mime_type ? -filename ? -- tmp_file

    default employee_id [auth]
    default filename [file tail $tmp_file]
    default mime_type [mime_type_guess [file tail $tmp_file]]

    set id [open $tmp_file r]
    fconfigure $id -translation binary
    set data [base64::encode [read $id]]
    close $id
   
    db_dml {update file set archived_date=now() where filename=:filename and archived_date is null}
    set file_id [db_seq file_id_seq]
    set qry {
	insert into file 
	(file_id,employee_id,filename,data)
	values 
	(:file_id,:employee_id,:filename,decode(:data,'base64'))
    }
    db_dml $qry
    file delete $tmp_file
    return $file_id
}

proc qc::db_file_export {args} {
    # Export a file in the db file table to a tmp local file
    args $args -tmp_file ? -- file_id

    default tmp_file /tmp/[uuid::uuid generate]
    db_1row {select filename, mime_type, encode(data,'base64') as base64 from file where file_id=:file_id}
    set id [open $tmp_file a+]
    fconfigure $id -translation binary
    puts $id [base64::decode $base64]
    close $id
    return $tmp_file
}

proc qc::plupload.html {name chunk chunks file} {
    # Keeps uploaded file parts sent by plupload and concat them once all parts have been sent.
    # File inserted into file table.
    set user_id [qc::auth]
    set file_id $name
    set tmp_file /tmp/$file_id.$chunk
    # Move the AOLserver generated tmp file to one we will keep
    file rename [ns_getformfile file] $tmp_file
    if { [nsv_exists pluploads $user_id] } {
	set dict [nsv_get pluploads $user_id]
    } else {
	set dict {}
    }
    dict set dict $file_id $chunk $tmp_file
    dict set dict $file_id chunks $chunks
    dict set dict $file_id filename $file

    set complete true
    foreach chunk [.. 0 $chunks-1] {
	if { ![dict exists $dict $file_id $chunk] } {
	    set complete false
	    break
	} else {
	    lappend files /tmp/$file_id.$chunk
	}
    }
    if { $complete } {
	# Join parts together
	exec_proxy cat {*}$files > /tmp/$file_id
	set file_id [qc::db_file_insert -employee_id $user_id -filename [dict get $dict $file_id filename] /tmp/$file_id]
	# Clean up
	foreach file $files {
	    file delete $file
	}
	dict unset dict $file_id
    } else {
	nsv_set pluploads $user_id $dict
    }
    return $file_id
}
