namespace eval qc {
    namespace export file_temp file_write file_upload
}

proc qc::file_temp {args} {
    #| Write the text $text out into a temporary file
    #| and return the name of the file.
    qc::args $args -binary -- contents {mode 0600}
    default binary false
    package require fileutil
    set filename [fileutil::tempfile]
    set switches {}
    if { $binary } {
        lappend switches -binary
    }
    qc::file_write {*}$switches -- $filename $contents $mode
    return $filename
}

proc qc::file_write {args} {
    # Return true if file has changed by writing to it.
    qc::args $args -binary -- filename contents {perms ""}
    default binary false
    if { $perms ne "" } {
	set perms [qc::format_right0 $perms 5]
    }
    if { ![file exists $filename]
         || [qc::cat $filename] ne $contents
         || [file attributes $filename -permissions]!=$perms
     } { 
        log Debug "writing ${filename} ..."
        set handle [open $filename w+ 00600]
        if { $binary } {
            fconfigure $handle -translation "binary"
        }
        puts -nonewline $handle $contents
        close $handle
        if { $perms ne "" } {
            # set file permissions
            file attributes $filename -permissions $perms
        }
        log Debug "written"
        return true
    } else {
        return false
    }
}

proc qc::file_upload {name chunk chunks file} {
    #| Keeps uploaded file parts sent by chunked upload and concat them once all parts have been sent.
    # returns filename of concat file when upload is complete ("" otherwise)
    set user_id [qc::auth]
    set id $name
    set tmp_file /tmp/$id.$chunk

    # Move the AOLserver generated tmp file to one we will keep
    file rename [ns_getformfile file] $tmp_file
    if { [nsv_exists uploads $user_id] } {
	set dict [nsv_get uploads $user_id]
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
        set file_path /tmp/$id
        set mime_type [qc::mime_type_guess $file]
        if { $mime_type ne "*/*" } {
            append file_path [qc::mime_file_extension $mime_type]
        }
        
        ::try {
            exec_proxy cat {*}$files > $file_path
        } finally {
            # Clean up
            foreach file $files {
                file delete $file
            }
        }
	dict unset dict $id
	nsv_set uploads $user_id $dict
	return $file_path
    } else {
	nsv_set uploads $user_id $dict
	return ""
    }
}

proc qc::cat {filename} {
    set handle [open $filename r]
    set contents [read $handle]
    close $handle
    return $contents
}

proc qc::file2url {file} {
    # Takes a file and returns url path relative to www root.
    set root [ns_pagepath]
    if { [string equal -length [string length $root] $root $file]
         && [string length $file] > [string length $root]
     } {
        return [string range $file [string length $root] end]
    } else {
        error "$file is outside page root $root"
    }
}

proc qc::file_cache_create {file_id file_path} {
    #| Create a file in the disk cache
    set file [qc::db_file_export $file_id]

    # Place files in cache
    if { ! [file exists [file dirname $file_path]] } {
        file mkdir [file dirname $file_path]
    }

    file rename -force $file $file_path

    return $file_path
}

proc qc::file_cache_data {file_id file_path} {
    #| Return dict containing canonical url of cached file.
    #| Return an empty dict if cached file does not exist.

    if { [nsv_exists file_cache_data $file_id] } {
        # File has been recorded in NSV file_cache_data.

        return [nsv_get file_cache_data $file_id]
    } elseif { [file exists $file_path]
               && [file isfile $file_path] } {
        # File exists on disk but hasn't been recorded in NSV file_cache_data.

        set url [qc::file2url $file_path]
        set data [dict_from url]
        nsv_set file_cache_data $file_id $data

        return $data
    } else {
        # File doesn't exist and hasn't been recorded in NSV file_cache_data.

        return [dict create]
    }
}

proc qc::file_data {file_id file_path} {
    #| Return dict containing url of file.
    #| Generates file cache if it doesn't already exist.
    if { ! [qc::file_cache_exists $file_id $file_path] } {
        qc::file_cache_create $file_id $file_path
    }

    return [qc::file_cache_data $file_id $file_path]
}

proc qc::file_cache_exists {file_id file_path} {
    #| Return true if this file has been cached on disk.
    if { [llength [qc::file_cache_data $file_id $file_path]] > 0 } {
        return true
    } else {
        return false
    }
}
