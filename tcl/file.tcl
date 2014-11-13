namespace eval qc {
    namespace export file_temp file_write file_upload
}

proc qc::file_temp {text {mode 0600}} {
    #| Write the text $text out into a temporary file
    #| and return the name of the file.
    package require fileutil
    set filename [fileutil::tempfile]
    set out [open $filename w $mode]
    puts -nonewline $out $text
    close $out
    return $filename
}

proc qc::file_write {filename contents {perms ""}} {
    # Return true if file has changed by writing to it.
    if { $perms ne "" } {
	set perms [qc::format_right0 $perms 5]
    }
    if { ![file exists $filename] || [qc::cat $filename] ne $contents || [file attributes $filename -permissions]!=$perms } { 
        log Debug "writing ${filename} ..."
        set handle [open $filename w+ 00600]
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
	exec_proxy cat {*}$files > /tmp/$id
	# Clean up
	foreach file $files {
	    file delete $file
	}
	dict unset dict $id
	nsv_set uploads $user_id $dict
	return /tmp/$id
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
    if { [regexp "^[ns_pagepath](.+)\$" $file -> url] } {
        return $url
    } else {
        error "$file is outside page root [ns_pagepath]"
    }
}