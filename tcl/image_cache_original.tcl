namespace eval qc {
}

proc qc::_image_cache_original_exists {
    cache_dir file_id
} {
    #| Test whether a filesystem cache of the original image file exists
    set glob_pattern "${file_id}.*"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    if { [llength [glob {*}$glob_options {*}$glob_pattern]] == 1 } {
        return true
    } else {
        return false
    }
}

proc qc::_image_cache_original_file {
    cache_dir file_id
} {
    #| Test whether a filesystem cache of the original image file exists
    set glob_pattern "${file_id}.*"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set matches [glob {*}$glob_options {*}$glob_pattern]
    return [lindex $matches 0]
}

proc qc::_image_cache_original_create {
    cache_dir file_id
} {
    #| Create a cache of an image in original form, in cache_dir
    #| Create symbolic link to cached image
    db_1row {
        select
        filename,
        width,
        height,
        mime_type
        
        from file
        join image using(file_id)
        
        where file_id=:file_id
    }
    if { $mime_type eq "image/svg+xml" } {
        set file [qc::db_file_export $file_id]
        file rename -force $file ${cache_dir}/${file_id}.svg
        return
    }
    
    set ext [file extension $filename]
    set cache_file_relative ${file_id}-${width}x${height}/${file_id}${ext}
    set cache_file ${cache_dir}/${cache_file_relative}
    if { ! [file exists $cache_file] } {
        set file [qc::db_file_export $file_id]
        qc::image_file_meta_strip $file
        
        file mkdir [file dirname $cache_file]
        file rename -force $file $cache_file
    }
    file link ${cache_dir}/${file_id}${ext} $cache_file_relative
}
