package provide qcode 1.15
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
    db_1row {select filename, encode(data,'base64') as base64 from file where file_id=:file_id}
    set id [open $tmp_file a+]
    fconfigure $id -translation binary
    puts $id [base64::decode $base64]
    close $id
    return $tmp_file
}

proc qc::db_file_thumbnailer {file_id {width ""} {height ""}} {
    #| Return image file resized to the given width and height.
    # Generated thumnails are cached.
    
    # Create the image cache if it doesn't exist yet
    if { ! [in [ns_cache_names] images] } {
	ns_cache create images -size [expr 100*1024*1024] 
    }
    db_1row {
	select filename, upload_date::timestamp(0) as file_created 
	from file where file_id=:file_id
    }
    set mime_type [ns_guesstype $filename]
    set headers [ns_conn headers]
    if { [ns_set find $headers If-Modified-Since]!=-1 } {
	set if_modified_since [ns_set iget $headers If-Modified-Since]
    }   
    if { $width ne "" && $height ne "" } {
	set key "$file_id $width $height"
    } else {
	set key $file_id
    }
    if { [info exists if_modified_since] && [clock scan $if_modified_since]>=[clock scan $file_created] } {
	# Return 304 - Unchanged
	ns_return 304 $mime_type ""
    } elseif { [ne [ns_cache names images $key] ""] } {
	# Cache exists
	set tmp_file /tmp/[uuid::uuid generate]
	set id [open $tmp_file a+]
	fconfigure $id -translation binary
	puts $id [ns_cache get images $key]
	close $id
	ns_returnfile 200 $mime_type $tmp_file
	file delete $tmp_file
    } else {
	# Pull from db
	set tmp_file [qc::db_file_export $file_id]
	if { $width ne "" && $height ne "" } {
	    # Resize and cache
	    set thumb /tmp/[uuid::uuid generate]
	    # Call imagemagick convert 
	    exec_proxy convert -thumbnail ${width}x${height} $tmp_file $thumb
	    file delete $tmp_file
	    set id [open $thumb r]
	    fconfigure $id -translation binary
	    set data [read $id]
	    close $id	
	    ns_cache set images $key $data
	    ns_returnfile 200 $mime_type $thumb
	    file delete $thumb
	} else {
	    # Return original file
	    ns_returnfile 200 $mime_type $tmp_file
	    file delete $tmp_file
	}
    }
}

proc qc::plupload.html {name chunk chunks file} {
    # Keeps uploaded file parts sent by plupload and concat them once all parts have been sent.
    # File inserted into file table.
    set user_id [qc::auth]
    set id $name
    set tmp_file /tmp/$id.$chunk
    # Move the AOLserver generated tmp file to one we will keep
    file rename [ns_getformfile file] $tmp_file
    if { [nsv_exists pluploads $user_id] } {
	set dict [nsv_get pluploads $user_id]
    } else {
	set dict {}
    }
    dict set dict $id $chunk $tmp_file
    dict set dict $id chunks $chunks
    dict set dict $id filename $file

    set complete true
    foreach chunk [.. 0 $chunks-1] {
	if { ![dict exists $dict $id $chunk] } {
	    set complete false
	    break
	} else {
	    lappend files /tmp/$id.$chunk
	}
    }
    if { $complete } {
	# Join parts together
	exec_proxy cat {*}$files > /tmp/$id
	set file_id [qc::db_file_insert -employee_id $user_id -filename [dict get $dict $id filename] /tmp/$id]
	# Clean up
	foreach file $files {
	    file delete $file
	}
	dict unset dict $id
	return $file_id	
    } else {
	nsv_set pluploads $user_id $dict
	return ""
    }
}
