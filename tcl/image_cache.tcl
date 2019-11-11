namespace eval qc {
    namespace export {*}{
        image_data
        image_cache_exists
        image_cache_data
        image_cache_create
    }
}
proc qc::image_data {args} {
    #| Return dict of width, height, & url of an image. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
    if { ! [qc::image_cache_exists {*}$args] } {
        qc::image_cache_create {*}$args
    }
    set cache_data [qc::image_cache_data {*}$args]

    return [dict_subset $cache_data url width height]
}

proc qc::image_cache_exists {args} {
    #| Return true if a cached version of the image exists. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
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

    if { [qc::image_nsv_cache_exists ~ {*}{
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }] } {
        return true
    }

    if { [qc::image_filesystem_cache_exists ~ {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
        
    }] } {
        return true
    }
    return false
}

proc qc::image_cache_data {args} {
    #| Return dict of width, height & url of an image from cache. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
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

    # Get data from nsv cache if possible
    set nsv_args [dict_from {*}{
        autocrop
        file_id
        mime_type
        max_width
        max_height
    }]
    if { [qc::image_nsv_cache_exists {*}$nsv_args] } {
        return [qc::image_nsv_cache_data {*}$nsv_args]
    }

    # Otherwise get data from filesystem cache,
    # and set nsv cache
    set data [qc::image_filesystem_cache_data ~ {*}{
        autocrop
        cache_dir
        file_id
        mime_type
        max_width
        max_height
    }]

    return $data
}

proc qc::image_cache_create {args} {
    #| Create a cache of an image. Usage:
    #| ?-autocrop? ?-mime_type */*? -- cache_dir file_id max_width max_height
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

    qc::image_filesystem_cache_create ~ {*}{
        autocrop
        cache_dir
        file_id
        max_width
        max_height
    }
}
