namespace eval qc {
    namespace export {*}{
        image_data
        image_cache_exists
    }
}
proc qc::image_data {args} {
    #| Return dict of width, height, & url of an image. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
    set caller_args $args
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
    if { ! [qc::image_cache_exists {*}$caller_args] } {
        if { $mime_type eq "*/*" } {
            if { ! [qc::_image_cache_original_exists $cache_dir $file_id] } {
                qc::_image_cache_original_create $cache_dir $file_id
            }
            set mime_type [qc::mime_type_guess \
                               [qc::_image_cache_original_file \
                                    $cache_dir $file_id]]
        }
        qc::_image_cache_create \
            $cache_dir $file_id $mime_type $max_width $max_height $autocrop
        
    } elseif { $mime_type eq "*/*" } {
        set available_types \
            [qc::_image_cache_available_mime_types {*}$caller_args]
        foreach preference {
            "image/png"
            "image/gif"
            "image/jpeg"
            "image/webp"
        } {
            if { [lsearch -exact $available_types $preference] > -1 } {
                set mime_type $preference
                break
            }
        }
    }
    set cache_data \
        [qc::_image_cache_data \
             $cache_dir $file_id $mime_type $max_width $max_height $autocrop]
    return $cache_data
}

proc qc::image_cache_exists {args} {
    #| Return true if a cached version of the image exists. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
    set caller_args $args
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
    
    foreach file [qc::_image_filesystem_cache_glob {*}$caller_args] {
        lassign \
            [qc::_image_filesystem_cache_file2dimensions $file] \
            width height

        if { ( $width == $max_width
               &&
               $height <= $max_height )
             ||
             ( $height == $max_height
               &&
               $width <= $max_width )
         } {
            return true
        }
    }
    return false
}

proc qc::_image_cache_available_mime_types {args} {
    #| Return a list of mime types for matching cache entries
    set caller_args $args
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

    set mime_type_flags [dict create]
    
    foreach file [qc::_image_filesystem_cache_glob {*}$caller_args] {
        lassign \
            [qc::_image_filesystem_cache_file2dimensions $file] \
            width height

        if { ( $width == $max_width
               &&
               $height <= $max_height )
             ||
             ( $height == $max_height
               &&
               $width <= $max_width )
         } {
            dict set mime_type_flags [qc::mime_type_guess $file] true
        }
    }
    return [dict keys $mime_type_flags]
}

proc qc::_image_cache_data {
    cache_dir file_id mime_type max_width max_height autocrop
} {
    #| Return dict of width, height & url of an image from cache.
    set glob_args [list]
    if { $autocrop } {
        lappend glob_args -autocrop
    }
    lappend glob_args \
        -mime_type $mime_type \
        -- \
        $cache_dir \
        $file_id \
        $max_width \
        $max_height
    
    foreach file [qc::_image_filesystem_cache_glob {*}$glob_args] {
        lassign \
            [qc::_image_filesystem_cache_file2dimensions $file] \
            width height

        if { ( $width == $max_width
               &&
               $height <= $max_height )
             ||
             ( $height == $max_height
               &&
               $width <= $max_width )
         } {
            set url [qc::file2url $file]
            set data [dict_from width height url]
            return $data
        }
    }
    error "No cache for $cache_dir $file_id $mime_type $max_width $max_height $autocrop"
}

proc qc::_image_cache_create {
    cache_dir file_id mime_type max_width max_height autocrop
} {
    #| Create a cache of an image with the given requirements
    if { ! [qc::_image_cache_original_exists $cache_dir $file_id] } {
        qc::_image_cache_original_create $cache_dir $file_id
    }
    set original [qc::_image_cache_original_file $cache_dir $file_id]
    
    set file [qc::image_file_convert \
                 $original $mime_type $max_width $max_height $autocrop]
    
    dict2vars [qc::image_file_info $file] width height

    set ext [qc::mime_file_extension $mime_type]
    set file_path_parts [list $cache_dir]
    if { $autocrop } {
        lappend file_path_parts \
            $file_id \
            autocrop \
            ${width}x${height}
    } else {
        lappend file_path_parts \
            ${file_id}-${width}x${height}
    }
    lappend file_path_parts ${file_id}${ext}

    set cache_file [join $file_path_parts "/"]

    file mkdir [file dirname $cache_file]
    file rename -force $file $cache_file
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
        height
        
        from file
        join image using(file_id)
        
        where file_id=:file_id
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
    if { $autocrop } {
        set glob_patterns \
            [list \
                 "${file_id}/autocrop/${max_width}x*/${file_id}.*" \
                 "${file_id}/autocrop/*x${max_height}/${file_id}.*"]

    } else {
        set glob_patterns \
            [list \
                 "${file_id}-${max_width}x*/${file_id}.*" \
                 "${file_id}-*x${max_height}/${file_id}.*"]
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
