namespace eval qc {
    namespace export {*}{
        image_nsv_cache_exists
        image_nsv_cache_data
        image_nsv_cache_create
        image_nsv_cache_smaller_biggest_exists
        image_nsv_cache_glob
        image_nsv_cache_file2dimensions
        image_nsv_cache_original_exists
        image_nsv_cache_original_data
        image_nsv_cache_original_create
        image_nsv_cache_autocrop_exists
        image_nsv_cache_autocrop_data
        image_nsv_cache_autocrop_create
    }
}

################################################################################
# NSV Cache of Image

proc qc::image_nsv_cache_exists {args} {
    #| Test whether an nsv cache of an image exists
    #| args: dict-style of file_id, width, height, autocrop
    qc::args2vars $args {*}{
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    # Requested size matches or exceeds full-sized image in cache
    if { [qc::image_nsv_cache_smaller_biggest_exists {*}$args] } {
        return true
    }

    # NSV cache key
    set nsv_pattern "$file_id $mime_type $autocrop"
    set names [nsv_array names image_cache_data $nsv_pattern]

    # No cache exists yet for this image with this autocrop flag
    if { [llength $names] == 0 } {
        return false
    }

    # Prefer non-webp mime_type
    if { $mime_type eq "*/*" } {
        foreach mime_type {
            "image/png"
            "image/gif"
            "image/jpeg"
            "image/webp"
        } {
            set nsv_key "$file_id $mime_type $autocrop"
            if { [lsearch -exact $names $nsv_key] > -1 } {
                break
            }
        }
    }

    # Cache is a dict with width-height pairs for keys,
    # Find one that matches the given constraints
    foreach {key value} [nsv_get image_cache_data $nsv_key] {
        lassign $key width height

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

proc qc::image_nsv_cache_data {args} {
    #| Return nsv image cache data
    #| args: dict-style of file_id, width, height, autocrop
    qc::args2vars $args {*}{
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    # Requested size matches or exceeds full-sized image in cache,
    # return full-sized image
    if { [qc::image_nsv_cache_smaller_biggest_exists {*}$args] } {
        if { $autocrop } {
            return [qc::image_nsv_cache_autocrop_data $file_id $mime_type]
        } else {
            return [qc::image_nsv_cache_original_data $file_id $mime_type]
        }
    }

    # Cache is a dict with width-height pairs for keys,
    # Find one that matches the given constraints
    set nsv_pattern "$file_id $mime_type $autocrop"
    set names [nsv_array names image_cache_data $nsv_pattern]
    
    # Prefer non-webp mime_type
    if { $mime_type eq "*/*" } {
        foreach mime_type {
            "image/png"
            "image/gif"
            "image/jpeg"
            "image/webp"
        } {
            set nsv_key "$file_id $mime_type $autocrop"
            if { [lsearch -exact $names $nsv_key] > -1 } {
                break
            }
        }
    }
    dict for {key value} [nsv_get image_cache_data $nsv_key] {
        lassign $key width height

        if { ( $width == $max_width
               &&
               $height <= $max_height )
             ||
             ( $height == $max_height
               &&
               $width <= $max_width )
         } {
            return $value
        }
    }

    error "No matching nsv image data cache exists"
}

proc qc::image_nsv_cache_set {args} {
    #| Set nsv cache of image data
    # (Cache is a dict with width-height pairs for keys)
    qc::args2vars $args {*}{
        autocrop
        file_id
        mime_type
        data
    }
    dict2vars $data width height
    set nsv_key "$file_id $mime_type $autocrop"
    if { [nsv_exists image_cache_data $nsv_key] } {
        set cache [nsv_get image_cache_data $nsv_key]
    } else {
        set cache [dict create]
    }
    dict set cache [list $width $height] $data
    nsv_set image_cache_data $nsv_key $cache
}

proc qc::image_nsv_cache_smaller_biggest_exists {args} {
    #| Test if a "biggest" (original & autocropped) version of the image
    #| exists in nsv cache, that is no bigger than the given restrictions
    qc::args2vars $args {*}{
        file_id
        max_width
        max_height
        autocrop
    }

    if { $autocrop } {
        set command_prefix "qc::image_nsv_cache_autocrop"
    } else {
        set command_prefix "qc::image_nsv_cache_original"
    }

    if { [${command_prefix}_exists $file_id]
     } {
        dict2vars [${command_prefix}_data $file_id] \
            width height
        
        if { $width <= $max_width
             && $height <= $max_height
         } {
            return true
        }
    }
    return false
}

################################################################################
# NSV Cache of Original Image

proc qc::image_nsv_cache_original_exists {file_id} {
    #| Test if the original of this image is in the nsv cache
    return [nsv_exists image_cache_data "$file_id original"]
}

proc qc::image_nsv_cache_original_data {file_id} {
    #| Get the original data for this image from nsv cache
    return [nsv_get image_cache_data "$file_id original"]
}

proc qc::image_nsv_cache_original_set {file_id data} {
    #| Set the data for the original of this image in nsv cache
    return [nsv_set image_cache_data "$file_id original" $data]
}

################################################################################
# NSV Cache of Autocrop Image

proc qc::image_nsv_cache_autocrop_exists {file_id} {
    #| Test if the autocrop of this image is in the nsv cache
    return [nsv_exists image_cache_data "$file_id autocrop"]
}

proc qc::image_nsv_cache_autocrop_data {file_id} {
    #| Get the autocrop data for this image from nsv cache
    return [nsv_get image_cache_data "$file_id autocrop"]
}

proc qc::image_nsv_cache_autocrop_set {file_id data} {
    #| Set the data for the autocrop of this image in nsv cache
    return [nsv_set image_cache_data "$file_id autocrop" $data]
}
