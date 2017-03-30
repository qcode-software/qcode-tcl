proc qc::image_original_data {cache_dir file_id} {
    #| Dict of image cache data at original dimensions, create if needed
    #| (file, width, height, url, timestamp)
    if { ! [qc::image_cache_original_exists $cache_dir $file_id] } {
        qc::image_cache_original_create $cache_dir $file_id
    }
    return [qc::image_cache_original_data $cache_dir $file_id]
}

proc qc::image_cache_original_exists {cache_dir file_id} {
    #| Check whether a cache exists of an image at its original dimensions
    if { [qc::image_nsv_cache_original_exists $file_id] } {
        return true
    }
    if { [qc::image_nsv_filesystem_original_exists $file_id] } {
        return true
    }
    return false
}

proc qc::image_cache_original_data {args} {
    #| Dict of image cache data at original dimensions
    #| (file, width, height, url, timestamp)
    #| (empty list if cache does not exist)
    if { [qc::image_nsv_cache_original_exists $file_id] } {
        return [qc::image_nsv_cache_original_data $file_id]
    }
    set data [qc::image_filesystem_cache_original_data {*}$args]
    qc::image_nsv_cache_original_set {*}$args $data
    return $data
}

proc qc::image_cache_original_create {args} {
    qc::args $args -autocrop -- cache_dir file_id max_width max_height
    default autocrop false

    set filesystem_args [dict from {*}{
        autocrop
        cache_dir
        file_id
        max_width
        max_height
    }]
    qc::image_filesystem_cache_original_create {*}$filesystem_args}
}