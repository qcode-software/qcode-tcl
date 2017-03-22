namespace eval qc {
    namespace export file_is_valid_image image_file_info image_resize image_file_autocrop image_file_resize
}

proc qc::image_file_autocrop {old_file {crop_colour white}} {
    #| Autocrop image by trimming white border from jpgs,
    #| and transparent and white borders from pngs.
    #| Create a new file with the results and return the file path
    set file /tmp/[uuid::uuid generate]
    set exec_proxy_flags {
        -timeout 20000
    }
    set exec_flags {
        -ignorestderr
    }
    set convert_options {
        -quiet
    }
    if { $crop_colour ne "" } {
        lappend convert_options \
            -bordercolor $crop_colour \
            -border 1x1
    }
    lappend convert_options {*}{
        -trim
        -format %wx%h%O info:
    }
    set crop_info \
        [exec_proxy \
             {*}$exec_proxy_flags \
             {*}$exec_flags \
             convert \
             $old_file \
             {*}$convert_options
             ]

    exec_proxy \
        {*}$exec_proxy_flags \
        {*}$exec_flags \
        convert \
        $old_file \
        -quiet \
        -crop $crop_info \
        +repage \
        $file

    return $file
}

proc qc::image_file_resize {old_file max_width max_height} {
    #| Resize an image to fit within max_width/height constraint.
    #| Create a new file with the results and return the file path
    set file /tmp/[uuid::uuid generate]
    set exec_proxy_flags {
        -timeout 30000
    }
    set exec_flags {
        -ignorestderr
    }
    set convert_flags [subst {
        -quiet
        -thumbnail ${max_width}x${max_height}
        -strip
        -quality 75%
    }]
    exec_proxy \
        {*}$exec_proxy_flags \
        {*}$exec_flags \
        convert \
        {*}$convert_flags \
        $old_file \
        $file

    return $file
}

proc qc::image_resize {args} {
    #| Export an image from the database, constrained to max width/height,
    #| optionally auto-cropped,
    #| return dict of file, width, and height
    qc::args $args -autocrop -- file_id max_width max_height
    default autocrop false

    set file [qc::db_file_export $file_id]
    
    if { $autocrop } {
        set tmp_file $file
        set file [qc::image_file_autocrop $tmp_file]
        file delete $tmp_file
    }

    dict2vars [qc::image_file_info $file] width height

    if { $width > $max_width
         || $height > $max_height
     } {
        set tmp_file $file
        set file [qc::image_file_resize $tmp_file $max_width $max_height]
        file delete $tmp_file
        dict2vars [qc::image_file_info $file] width height
    }

    return [qc::dict_from file width height]
}

proc qc::file_is_valid_image {file} {
    #| file (on local file system) is of an image type that we can stat.
    package require jpeg
    package require png

    return [expr {[jpeg::isJPEG $file] || [png::isPNG $file] || [qc::is_gif $file]}]
}

proc qc::image_file_info {file} {
    #| dict of width, height, and mime_type of file (from local filesystem)
    package require jpeg
    package require png

    if { [jpeg::isJPEG $file] } {
        lassign [jpeg::dimensions $file] width height
        set mime_type "image/jpeg"
    } elseif { [png::isPNG $file] } {
        qc::dict2vars [png::imageInfo $file] width height
        set mime_type "image/png"
    } elseif { [qc::is_gif $file] } {
        lassign [qc::gif_dimensions $file] width height
        set mime_type "image/gif"
    } else {
        error "Unrecognised image type"
    }
    return [qc::dict_from width height mime_type]
}

proc qc::is_gif {name} {
    set f [open $name r]
    fconfigure $f -translation binary
    # read GIF signature -- check that this is
    # either GIF87a or GIF89a
    set sig [read $f 6]
    switch $sig {
        "GIF87a" -
        "GIF89a" {
            close $f
            return true
        }
        default {
            close $f
            return false
        }
    }
 }

proc qc::gif_dimensions {name} {
    set f [open $name r]
    fconfigure $f -translation binary
    # read GIF signature -- check that this is
    # either GIF87a or GIF89a
    set sig [read $f 6]
    switch $sig {
        "GIF87a" -
        "GIF89a" {
            # do nothing
        }
        default {
            close $f
            error "$f is not a GIF file"
        }
    }
    # read "logical screen size", this is USUALLY the image size too.
    # interpreting the rest of the GIF specification is left as an exercise
    binary scan [read $f 2] s wid
    binary scan [read $f 2] s hgt
    close $f

    return [list $wid $hgt]
}

proc qc::image_cache_exists {args} {
    #| Return true if this image (constrained to max_width & max_height) has been cached on disk.
    if { [llength [qc::image_cache_data {*}$args]] > 0 } {
        return true
    } else {
        return false
    }
}

proc qc::image_cache_data {args} {
    #| Return dict of width, height & url of cached image constrained to max_width & max_height.
    #| Return {} if cached image does not exist.
    qc::args $args -autocrop -- cache_dir file_id max_width max_height
    default autocrop false

    # Image cache data stored in nsv when first requested
    if { $autocrop } {
        set nsv_key "$file_id $max_width $max_height autocrop"
    } else {
        set nsv_key "$file_id $max_width $max_height"
    }

    if { [nsv_exists image_cache_data $nsv_key] } {
        return [nsv_get image_cache_data $nsv_key]
    }

    # If not stored in nsv, check local filesystem

    # A suitable cached image will have one of:
    # width exactly equal to max_width, and height less than max height
    # height exactly equal to max_height, and width less than max width
    # width and height exactly equal to max width and height
    # (Only one such image should exist, since all chached images should
    #  be based on the same aspect ratio)

    # Construct glob patterns to search for candidate cached images,
    # and regex to extract actual image width and height from file path
    if { $autocrop } {
        set glob_patterns \
            [list \
                 "${file_id}/autocrop/${max_width}x*/${file_id}.*" \
                 "${file_id}/autocrop/*x${max_height}/${file_id}.*"]
        
        set expression {^/image/[0-9]+/autocrop/([0-9]+)x([0-9]+)/}

    } else {
        set glob_patterns \
            [list \
                 "${file_id}-${max_width}x*/${file_id}.*" \
                 "${file_id}-*x${max_height}/${file_id}.*"]
        
        set expression {^/image/[0-9]+-([0-9]+)x([0-9]+)/}
    }
    
    set data [list]
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    foreach file [lunique [glob {*}$glob_options {*}$glob_patterns]] {
        set url [qc::file2url $file]
        regexp $expression $url -> width height
        if { $width<=$max_width && $height<=$max_height } {
            set timestamp [qc::cast timestamp [file mtime $file]]
            set data [dict_from width height url timestamp]
            nsv_set image_cache_data $nsv_key $data
            return $data
        }
    }
        
    return [list]
}

proc qc::image_cache_create {args} {
    #| Create a file for this image in the disk cache,
    #| constrained to max_width & max_height,
    #| optionally auto-cropped,
    qc::args $args -autocrop -- cache_dir file_id max_width max_height
    default autocrop false
    set resize_args [list]
    if { $autocrop } {
        lappend resize_args -autocrop
    }
    lappend resize_args $file_id $max_width $max_height
    dict2vars [qc::image_resize {*}$resize_args] file width height

    # Place files in cache
    db_1row {select mime_type from file where file_id=:file_id}

    if { $autocrop } {
        set cache_file ${cache_dir}/${file_id}/autocrop/${width}x${height}/${file_id}[qc::mime_file_extension $mime_type]
    } else {
        set cache_file ${cache_dir}/${file_id}-${width}x${height}/${file_id}[qc::mime_file_extension $mime_type]
    }

    if { ! [file exists [file dirname $cache_file]] } {
        file mkdir [file dirname $cache_file]
    }
    file rename -force $file $cache_file
    
    return [dict create width $width height $height file $cache_file]
}

proc qc::image_data {args} {
    #| Return dict of width, height & url of image,
    #| constrained to max_width & max_height, optionally auto-cropped
    #| Generates image cache if it doesn't already exist.
    if { ! [qc::image_cache_exists {*}$args] } {
        qc::image_cache_create {*}$args
    }
    set cache_data [qc::image_cache_data {*}$args]

    return [dict_subset $cache_data url width height]
}

proc qc::image_handler {
    cache_dir
    {error_handler "qc::error_handler"}
    {image_redirect_handler "qc::image_redirect_handler"}
    {allowed_max_width 2560}
    {allowed_max_height 2560}
} {
    #| URL handler to serve images that can not be served by fastpath.
    # Create image cache for canonical URL if it doesn't already exist.
    # If canonical URL was requested return file to client,
    # and register URL to be servered by fastpath for future requests.
    # Otherwise default redirect handler will redirect client,
    # to correct image dimensions or the canonical URL.
    # By default enforce a max width and height of 2560x2560
    # Uses default qc::error_handler
    setif error_handler "" "qc::error_handler"
    ::try {
        set request_path [qc::conn_path]
        setif image_redirect_handler "" "qc::image_redirect_handler"
        
        if { [regexp {^/image/([0-9]+)-([0-9]+)x([0-9]+)(?:/(.*)|$)} \
                  $request_path -> file_id max_width max_height filename]
         } {
            set autocrop false
        } elseif { [regexp {^/image/([0-9]+)/autocrop/([0-9]+)x([0-9]+)(?:/(.*)|$)} \
                        $request_path -> file_id max_width max_height filename]
               } {
            set autocrop true
        } else {
            # Invalid image url
            return [ns_returnnotfound]
        }
        
        # Check requested max width and height does not exceed allowed maximums
        if { ($allowed_max_width ne "" && $max_width > $allowed_max_width)
             || ($allowed_max_height ne "" && $max_height > $allowed_max_height)
         } {
            return [ns_returnbadrequest "The requested image (${max_width}x${max_height}) exceeds the maximum width and height permitted (${allowed_max_width}x${allowed_max_height})."]
        }

        set cache_args [list]
        if { $autocrop } {
            lappend cache_args -autocrop
        }
        lappend cache_args $cache_dir $file_id $max_width $max_height

        # Canonical URL
        if { [qc::image_cache_exists {*}$cache_args] } {
            # Cache already exists for canonical url
            dict2vars [qc::image_cache_data {*}$cache_args] width height url
            set canonical_url $url
            set canonical_file [ns_pagepath]$canonical_url
        } else {
            # Create cache for canonical url
            
            # Check file exists
            db_0or1row {
                select 
                file_id
                from file
                join image using (file_id)
                where file_id=:file_id
            } {
                return [ns_returnnotfound]
            } 

            dict2vars [qc::image_cache_create {*}$cache_args] width height file
            set canonical_url [qc::file2url $file]
            set canonical_file $file
        } 
        if { $request_path eq $canonical_url } {
            # Canonical URL was requested - return file
            ns_register_fastpath GET $canonical_url
            ns_register_fastpath HEAD $canonical_url
            return [ns_returnfile 200 [mime_type_guess $canonical_file] $canonical_file]
        } 

        # Redirect handler
        return [$image_redirect_handler $cache_dir]
    } on error {error_message options} {
        # Error handler
        return [$error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]]
    }
}

proc qc::image_redirect_handler {cache_dir}  {
    #| Redirect client to correct image dimesions or the canonical URL.
    set request_path [qc::conn_path]

    if { [regexp {^/image/([0-9]+)-([0-9]+)x([0-9]+)(?:/(.*)|$)} \
              $request_path -> file_id max_width max_height filename]
     } {
        set autocrop false
    } else {
        regexp {^/image/([0-9]+)/autocrop/([0-9]+)x([0-9]+)(?:/(.*)|$)} \
            $request_path -> file_id max_width max_height filename
        set autocrop true
    }

    if { $autocrop } {
        dict2vars \
            [qc::image_cache_data \
                 -autocrop $cache_dir $file_id $max_width $max_height] \
            width height url
    } else {
        dict2vars \
            [qc::image_cache_data $cache_dir $file_id $max_width $max_height] \
            width height url
    }
    set canonical_url $url
    set canonical_file [ns_pagepath]$canonical_url
    
    # Check requested image dimensions
    if { $width != $max_width || $height != $max_height } {            
        # Redirect to url with correct image dimensions 
        return [ns_returnredirect \
                    "[conn_location][file dirname $canonical_url]/$filename"]
    }
    
    # Catch All - redirect to Canonical URL
    return [ns_returnredirect $canonical_url]      
}