namespace eval qc {
}

proc qc::_image_filesystem_cache_glob {args} {
    #| Return a list of files on the filesystem cache that match the given
    #| file_id, and match at least one size contraint exactly
    qc::args $args {*}{
        -autocrop
        -mime_type */*
        --
        cache_dir
        file_id
        max_width
        max_height
    }
    default autocrop false
    if { $mime_type eq "*/*" } {
        set extension ".*"
    } else {
        # Construct a case-insensitive glob pattern
        set extension ""
        foreach char [split [qc::mime_file_extension $mime_type] ""] {
            if { [string is alpha $char] } {
                append extension \[
                append extension [string tolower $char]
                append extension [string toupper $char]
                append extension \]
            } else {
                append extension $char
            }
        }
    }
    if { $autocrop } {
        set glob_patterns \
            [list \
                 "${file_id}/autocrop/${max_width}x*/${file_id}${extension}" \
                 "${file_id}/autocrop/*x${max_height}/${file_id}${extension}"]

    } else {
        set glob_patterns \
            [list \
                 "${file_id}-${max_width}x*/${file_id}${extension}" \
                 "${file_id}-*x${max_height}/${file_id}${extension}"]
    }
    
    set data [list]
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set return_data [list]
    return [glob {*}$glob_options {*}$glob_patterns]
}

proc qc::_image_filesystem_cache_glob2 {args} {
    #| Return a list of files on the filesystem cache that match the given
    #| file_id, mime_type and match at least one size constraint exactly
    qc::args $args {*}{
        -autocrop
        --
        cache_dir
        file_id
        mime_type
        max_width
        max_height
    }
    default autocrop false
    
    # Construct a case-insensitive glob pattern
    set extension ""
    foreach char [split [qc::mime_file_extension $mime_type] ""] {
        if { [string is alpha $char] } {
            append extension \[
            append extension [string tolower $char]
            append extension [string toupper $char]
            append extension \]
        } else {
            append extension $char
        }
    }
    
    if { $autocrop } {
        set glob_patterns \
            [list \
                 "${file_id}/autocrop/${max_width}x*/${file_id}${extension}" \
                 "${file_id}/autocrop/*x${max_height}/${file_id}${extension}"]

    } else {
        set glob_patterns \
            [list \
                 "${file_id}-${max_width}x*/${file_id}${extension}" \
                 "${file_id}-*x${max_height}/${file_id}${extension}"]
    }
    
    set data [list]
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set return_data [list]
    return [glob {*}$glob_options {*}$glob_patterns]
}

proc qc::_image_filesystem_cache_file2dimensions {file} {
    #| Extract the width and height from a filesystem cache path
    set expression {[^0-9]([0-9]+)x([0-9]+)[^0-9]}
    regexp $expression $file -> width height
    return [list $width $height]
}
