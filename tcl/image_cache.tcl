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

    default \
        autocrop false

    if { ! [qc::image_cache_exists {*}$caller_args] } {
        # Queue the image to be cached and return a placeholder.

        if { $autocrop } {
            qc::image_resize_task_add \
                -autocrop \
                -mime_type $mime_type \
                -cache_dir $cache_dir \
                -- \
                $file_id \
                $max_width \
                $max_height
        } else {
            qc::image_resize_task_add \
                -mime_type $mime_type \
                -cache_dir $cache_dir \
                -- \
                $file_id \
                $max_width \
                $max_height
        }

        set filename "${max_width}x${max_height}.png"
        set url [qc::url "https://via.placeholder.com/:filename" \
                     filename $filename \
                     text "queued for processing" \
                    ]

        return [dict create \
                    width $max_width \
                    height $max_height \
                    url $url \
                   ]
    }

    if { $mime_type eq "*/*" } {
        # We have a cached file for the args but no mime-type specified
        set available_types \
            [qc::_image_cache_available_mime_types {*}$caller_args]
        # Preference to use if no mime-type specified
        foreach preference {
            "image/svg+xml"
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

proc qc::image_data2 {args} {
    #| Return dict of width, height, & url of an image. Usage:
    #| ?-autocrop? -- cache_dir file_id mime_type max_width max_height
    set caller_args $args
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
    if { ! [qc::image_cache_exists2 {*}$caller_args] } {
        qc::_image_cache_create \
            $cache_dir $file_id $mime_type $max_width $max_height $autocrop
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
    # Special treatment for svg images
    if { $mime_type in [list "*/*" "image/svg+xml"]
         && [qc::_image_cache_original_exists $cache_dir $file_id]
             && [qc::mime_type_guess \
                     [qc::_image_cache_original_file $cache_dir $file_id]] \
             eq "image/svg+xml" } {
        return true
    }
    
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

proc qc::image_cache_exists2 {args} {
    #| Return true if a cached version of the image exists. Usage:
    #| ?-autocrop? -- cache_dir file_id mime_type max_width max_height
    set caller_args $args
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
    # Special treatment for svg
    if { $mime_type eq "image/svg+xml"
         && [qc::_image_cache_original_exists $cache_dir $file_id]
             && [qc::mime_type_guess \
                     [qc::_image_cache_original_file $cache_dir $file_id]] \
             eq "image/svg+xml" } {
        return true
    }
    
    foreach file [qc::_image_filesystem_cache_glob2 {*}$caller_args] {
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
    # Special treatment for svg
    if { $mime_type eq "image/svg+xml"
         && [qc::_image_cache_original_exists $cache_dir $file_id]
         && [qc::mime_type_guess \
                 [qc::_image_cache_original_file $cache_dir $file_id]] \
             eq "image/svg+xml" } {
        dict set mime_type_flags "image/svg+xml" true
    }
    
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
    # Special treatment for svg
    if { $mime_type in [list "*/*" "image/svg+xml"]
         && [qc::_image_cache_original_exists $cache_dir $file_id]
         && [qc::mime_type_guess \
                 [qc::_image_cache_original_file $cache_dir $file_id]] \
             eq "image/svg+xml" } {
        set file [qc::_image_cache_original_file $cache_dir $file_id]
        lassign [qc::svg_dimensions $file] width height
        if { $width > $max_width
             ||
             $height > $max_height } {
            set scale [expr {min(
                                 1.0 * $max_width / $width,
                                 1.0 * $max_height / $height
                                 )}]
            set width [qc::round [expr {$scale * $width}] 0]
            set height [qc::round [expr {$scale * $height}] 0]
        }        
        set url [qc::file2url $file]
        set data [dict_from width height url]
        return $data
    }
    
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
    # The original will suffice for svg
    if { $mime_type eq "image/svg+xml" } {
        return
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
