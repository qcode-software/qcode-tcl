namespace eval qc {
    namespace export {*}{
        file_is_valid_image
        image_file_info
        image_resize
        image_file_autocrop
        image_file_resize
        image_file_convert
    }
}

proc qc::image_file_meta_strip {file} {
    #| Strip metadata from a file
    exec_proxy \
        -timeout 20000 \
        -ignorestderr \
        convert \
        $file \
        -quiet \
        -strip \
        -density 0 \
        $file
    
    return $file
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
    # Deprecated
    qc::args $args -autocrop -- file_id max_width max_height
    default autocrop false

    set file [qc::db_file_export $file_id]
    
    if { $autocrop } {
        set tmp_file $file
        ::try {
            set file [qc::image_file_autocrop $tmp_file]
        } finally {
            file delete $tmp_file
        }
    }

    dict2vars [qc::image_file_info $file] width height

    # Check whether image needs resizing
    if { $width > $max_width
         || $height > $max_height
     } {
        set tmp_file $file
        ::try {
            set file [qc::image_file_resize $tmp_file $max_width $max_height]
        } finally {
            file delete $tmp_file
        }
        dict2vars [qc::image_file_info $file] width height
    }

    return [qc::dict_from file width height]
}

proc qc::file_is_valid_image {file} {
    #| file (on local file system) is of an image type that we can stat.
    package require jpeg
    package require png

    return [expr {
                  [jpeg::isJPEG $file]
                  || [png::isPNG $file]
                  || [qc::is_gif $file]
                  || [qc::is_webp $file]
                  || [qc::is_svg $file]}]
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
    } elseif { [qc::is_webp $file] } {
        lassign [qc::webpsize $file] width height
        set mime_type "image/webp"
    } elseif { [qc::is_svg $file] } {
        lassign [qc::svg_dimensions $file] width height
        set mime_type "image/svg+xml"
    } else {
        error "Unrecognised image type"
    }
    return [qc::dict_from width height mime_type]
}

proc qc::is_gif {file} {
    set f [open $file r]
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
        } elseif { [regexp {^/image/([0-9]+)\.svg$} \
                        $request_path -> file_id] } {
            dict2vars [qc::image_data \
                           -mime_type "image/svg+xml" \
                           $cache_dir \
                           $file_id \
                           $allowed_max_width \
                           $allowed_max_height] url
            set file [ns_pagepath]$url
            ns_register_fastpath GET $url
            ns_register_fastpath HEAD $url
            return [ns_returnfile 200 "image/svg+xml" $file]
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

        set mime_type [qc::mime_type_guess $filename]

        set cache_args [list]
        if { $autocrop } {
            lappend cache_args -autocrop
        }
        lappend cache_args \
            -mime_type $mime_type \
            -- $cache_dir $file_id $max_width $max_height
        
        dict2vars [qc::image_data {*}$cache_args] width height url
        set canonical_url $url
        set canonical_file [ns_pagepath]$url

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

    set mime_type [qc::mime_type_guess $filename]

    if { $autocrop } {
        dict2vars \
            [qc::image_cache_data \
                 -autocrop \
                 -mime_type $mime_type \
                 -- $cache_dir $file_id $max_width $max_height] \
            width height url
    } else {
        dict2vars \
            [qc::image_cache_data \
                 -mime_type $mime_type \
                 -- $cache_dir $file_id $max_width $max_height] \
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

proc qc::image_file_convert {old_file mime_type max_width max_height autocrop} {
    #| Convert an image, return file path of new image
    set ext [qc::mime_file_extension $mime_type]
    set file /tmp/[uuid::uuid generate]${ext}

    if { $autocrop } {
        set old_file [qc::image_file_autocrop $old_file]
    }
    
    set exec_proxy_flags {
        -timeout 30000
    }
    set exec_flags {
        -ignorestderr
    }
    set convert_flags {
        -quiet
        -strip
    }
    if { $mime_type eq "image/webp" } {
        lappend convert_flags \
            -quality 100%            
    } else {
        lappend convert_flags \
            -quality 75%
    }
    lappend convert_flags \
        -thumbnail ${max_width}x${max_height}
    
    exec_proxy \
        {*}$exec_proxy_flags \
        {*}$exec_flags \
        convert \
        $old_file \
        {*}$convert_flags \
        $file
    
    if { $autocrop } {
        file delete $old_file
    }

    return $file
}

proc qc::is_svg {file} {
    #| Test if file is an SVG file
    set f [open $file r]
    if { [read $f 5] eq "<svg " } {
        close $f
        return true
    } else {
        close $f
        return false
    }
}

proc qc::svg_dimensions {file} {
    #| Get the preferred dimensions of an SVG file
    package require tdom
    set f [open $file r]
    set svg [read $f]
    dom parse $svg doc
    set root [$doc documentElement]

    # Check for width and/or height attributes
    if { [$root hasAttribute "width"] } {
        set width [$root getAttribute "width"]
        set width [qc::svg_units2pixels $width]
    }
    
    if { [$root hasAttribute "height"] } {
        set height [$root getAttribute "height"]
        set height [qc::svg_units2pixels $height]
    }
    
    if { [info exists width] && [info exists height] } {
        return [list $width $height]
    }

    # Check for viewbox attribute
    if { [$root hasAttribute "viewBox"] } {
        set viewBox [$root getAttribute "viewBox"]
        lassign [split $viewBox] min_x min_y box_width box_height
        if { [info exists width] } {
            set ratio [expr {1.0 * $box_height / $box_width}]
            set height [qc::round [expr {$width * $ratio}] 0]
            return [list $width $height]
        }
        if { [info exists height] } {
            set ratio [expr {1.0 * $box_width / $box_height}]
            set width [qc::round [expr {$height * $ratio}] 0]
            return [list $width $height]
        }
        return [list \
                    [qc::round $box_width 0] \
                    [qc::round $box_height 0]]
    }

    # Most browsers now use 300x150 as the default
    return [list 300 150]
}

proc qc::svg_units2pixels {length} {
    #| Convert supported svg distance units to pixels
    if { ! [regexp \
                {^([0-9]+(?:\.[0-9]+))([a-zA-Z]*)$} \
                $length \
                -- number units] } {
        error "Unable to parse length \"$length\""
    }
    switch [string tolower $units] {
        "" -
        "px" {
            set pixels $number
        }
        "in" {
            set pixels [expr {$number * 96}]
        }
        "cm" {
            set pixels [expr {$number * 37.795}]
        }
        "mm" {
            set pixels [expr {$number * 3.7795}]
        }
        "pt" {
            set pixels [expr {$number * 1.3333}]
        }
        "pc" {
            set pixels [expr {$number * 16}]
        }
        default {
            error "Unrecognized units \"$units\""
        }
    }
    return [qc::round $pixels 0]
}
