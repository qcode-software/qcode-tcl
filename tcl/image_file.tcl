namespace eval qc {
    namespace export file_is_valid_image image_file_info image_resize
}

proc qc::image_resize {file_id max_width max_height} {
    #| Resize an image, return dict of file location width height.
    # Create thumbnail
    set tmp_file [qc::db_file_export $file_id]
    set file /tmp/[uuid::uuid generate]
    # Call imagemagick convert
    set exec_proxy_flags {
        -timeout 10000
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
    exec_proxy {*}$exec_proxy_flags {*}$exec_flags convert {*}$convert_flags $tmp_file $file
    file delete $tmp_file    
    dict2vars [qc::image_file_info $file] width height
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

proc qc::image_cache_exists {cache_dir file_id max_width max_height} {
    #| Return true if this image constrained to max_width & max_height has been cached on disk.
    if { [llength [qc::image_cache_data $cache_dir $file_id $max_width $max_height]] > 0 } {
        return true
    } else {
        return false
    }
}

proc qc::image_cache_data {cache_dir file_id max_width max_height} {
    #| Return dict of width, height & url of cached image constrained to max_width & max_height.
    #| Return {} if cached image does not exist.

    # check nsv
    set nsv_key "$file_id $max_width $max_height"
    if { [nsv_exists image_cache_data $nsv_key] } {
        return [nsv_get image_cache_data $nsv_key]
    }
    
    # check disk cache for canonical URL
    set data {}
    set options [list -nocomplain -types f -directory $cache_dir]
    foreach file [lunique [glob {*}$options "${file_id}-${max_width}x*/${file_id}.*" "${file_id}-*x${max_height}/${file_id}.*"]] {
        set url [qc::file2url $file]
        regexp {^/image/[0-9]+-([0-9]+)x([0-9]+)/} $url -> width height  
        if { $width<=$max_width && $height<=$max_height } {
            set data [dict_from width height url]
            nsv_set image_cache_data $nsv_key $data
            return $data
        }
    }
        
    return {}
}

proc qc::image_cache_create {cache_dir file_id max_width max_height} {
    #| Create a file for this image in the disk cache constrained to max_width & max_height
    dict2vars [qc::image_resize $file_id $max_width $max_height] file width height

    # Place files in cache
    db_1row {select mime_type from file where file_id=:file_id}
    set cache_file ${cache_dir}/${file_id}-${width}x${height}/${file_id}[qc::mime_file_extension $mime_type]
    if { ! [file exists [file dirname $cache_file]] } {
        file mkdir [file dirname $cache_file]
    }
    file rename -force $file $cache_file
    log Debug "Created new cache $cache_file [dict_from max_width max_height width height]"

    return [dict create width $width height $height file $cache_file]
}

proc qc::image_data {file_id max_width max_height} {
    #| Return dict of width, height & url of image constrained to max_width & max_height.
    #| Generates image cache if it doesn't already exist to improve performance.
    if { ! [qc::image_cache_exists $file_id $max_width $max_height] } {
        log Debug "Image Data - Create canonical image cache"
        qc::image_cache_create $file_id $max_width $max_height
    }
    return [qc::image_cache_data $file_id $max_width $max_height]
}

proc qc::image_handler {cache_dir {image_redirect_handler UNDEF}} {
    #| Handle any image requests that aren't already registered to a fastpath handler
    # Redirects to correct aspect ratio, creates a file if needed, and registers new fastpath handlers for future requests
    log Debug "Hit Image Handler: [qc::conn_path]"
    set request_path [qc::conn_path]
    
    if { ! [regexp {^/image/([0-9]+)-([0-9]+)x([0-9]+)(?:/(.*)|$)} $request_path -> file_id max_width max_height filename] } {
        # Invalid image url
        log Debug "Image Handler - Invalid image url"
        return [ns_returnnotfound]
    }

    # Canonical URL
    if { [qc::image_cache_exists $cache_dir $file_id $max_width $max_height] } {
        # Cache already exists for canonical url
        dict2vars [qc::image_cache_data $cache_dir $file_id $max_width $max_height] width height url
        set canonical_url $url
        set canonical_file [ns_pagepath]$canonical_url
    } else {
        # Create cache for canonical url
        log Debug "Image Handler - Create canonical image cache"

        # Check file exists
        db_0or1row {
            select 
            file_id
            from file
            where file_id=:file_id
        } {
            log Debug "Image Handler - File not found"
            return [ns_returnnotfound]
        } 

        dict2vars [qc::image_cache_create $cache_dir $file_id $max_width $max_height] width height file
        set canonical_url [qc::file2url $file]
        set canonical_file $file
    } 
    if { $request_path eq $canonical_url } {
        # Canonical URL was requested - return file
        log Debug "Image Handler - Return file for canonical_url"
        ns_register_fastpath GET $canonical_url
        ns_register_fastpath HEAD $canonical_url
        return [ns_returnfile 200 [mime_type_guess $canonical_file] $canonical_file]
    } 

    if { $image_redirect_handler eq "UNDEF" } {
        return [qc::image_redirect_handler $cache_dir]
    } else {
        return [$image_redirect_handler $cache_dir]
    }
}

proc qc::image_redirect_handler {cache_dir}  {
    log Debug "Hit Image Redirect Handler: [qc::conn_path]"
    set request_path [qc::conn_path]

    regexp {^/image/([0-9]+)-([0-9]+)x([0-9]+)(?:/(.*)|$)} $request_path -> file_id max_width max_height filename
    dict2vars [qc::image_cache_data $cache_dir $file_id $max_width $max_height] width height url
    set canonical_url $url
    set canonical_file [ns_pagepath]$canonical_url
    
    # Check requested image dimensions
    if { $width != $max_width || $height != $max_height } {            
        # Redirect to url with correct image dimensions 
        log Debug "Image Handler - Wrong image dimesions requested - redirect to url with correct image dimensions"   
        return [ns_returnredirect "[conn_location][file dirname $canonical_url]/$filename"]
    }
    
    # Catch All - redirect to Canonical URL
    log Debug "Image Handler - Catch all redirect to canonical_url"
    return [ns_returnredirect $canonical_url]      
}