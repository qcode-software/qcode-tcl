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

proc qc::file_handler {cache_dir {error_handler "qc::error_handler"}} {
    #| URL handler to serve files that can not be served by fastpath.
    # If canonical url was requested return file to client and register URL to be servered by fastpath for future requests.
    setif error_handler "" "qc::error_handler"
    ::try {
        set request_path [qc::conn_path]
        
        if { [regexp {^/file/([0-9]+)(?:/.*|$)} $request_path -> file_id] } {
            # Valid file url
            
            if { [qc::file_cache_exists $cache_dir $file_id] } {
                # Cache already exists for canonical url
                dict2vars [qc::file_cache_data $cache_dir $file_id] url
                set canonical_url $url
                set canonical_file [ns_pagepath]$canonical_url
            } else {
                # Create cache for canonical url

                # Check file exists
                db_0or1row {
                    select 
                    file_id
                    from file
                    where file_id=:file_id
                } {
                    return [ns_returnnotfound]
                } 

                set canonical_file [qc::file_cache_create $cache_dir $file_id]
                set canonical_url [qc::file2url $canonical_file]
            } 
            if { $request_path eq $canonical_url } {
                # Canonical URL was requested - return file
                ns_register_fastpath GET $canonical_url
                ns_register_fastpath HEAD $canonical_url
                return [ns_returnfile 200 [mime_type_guess $canonical_file] $canonical_file]
            } 
        }

        # Catch All - redirect to Canonical URL
        return [ns_returnredirect $canonical_url]      
    } on error {error_message options} {
        # Error handler
        return [$error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]]
    }
}

proc qc::file_cache_create {cache_dir file_id} {
    #| Create a file in the disk cache
    set file [qc::db_file_export $file_id]

    # Place files in cache
    db_1row {select mime_type from file where file_id=:file_id}
    set cache_file ${cache_dir}/${file_id}/${file_id}[qc::mime_file_extension $mime_type]
    if { ! [file exists [file dirname $cache_file]] } {
        file mkdir [file dirname $cache_file]
    }
    file rename -force $file $cache_file

    return $cache_file
}

proc qc::file_cache_data {cache_dir file_id} {
    #| Return url of cached file.
    #| Return {} if cached file does not exist.

    # Check nsv
    set nsv_key "$file_id"
    if { [nsv_exists file_cache_data $nsv_key] } {
        return [nsv_get file_cache_data $nsv_key]
    }
    
    # Check disk cache for canonical URL (/file/${file_id}/${file_id}${extension})
    set data {}
    set options [list -nocomplain -types f -directory $cache_dir]
    set files [glob {*}$options "${file_id}/${file_id}.*"]
    if { [llength $files] > 0 } {
        set url [qc::file2url [lindex $files 0]]
        set data [dict_from url]
        nsv_set image_cache_data $nsv_key $data
        return $data
    } else {
        return {}
    }
}

proc qc::file_data {cache_dir file_id} {
    #| Return dict containing url of file.
    #| Generates file cache if it doesn't already exist.
    if { ! [qc::file_cache_exists $cache_dir $file_id] } {
        qc::file_cache_create $cache_dir $file_id
    }
    return [qc::file_cache_data $cache_dir $file_id]
}

proc qc::file_cache_exists {cache_dir file_id} {
    #| Return true if this file has been cached on disk.
    if { [llength [qc::file_cache_data $cache_dir $file_id]] > 0 } {
        return true
    } else {
        return false
    }
}