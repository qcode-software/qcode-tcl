namespace eval qc {
    namespace export {*}{
        image_original_data
        image_cache_original_exists
        image_cache_original_data
        image_cache_original_create
    }
}

proc qc::image_original_data {cache_dir file_id mime_type} {
    #| Dict of image cache data at original dimensions, create if needed
    #| (file, width, height, url, timestamp)
    if { ! [qc::image_cache_original_exists $cache_dir $file_id $mime_type] } {
        qc::image_cache_original_create $cache_dir $file_id $mime_type
    }
    return [qc::image_cache_original_data $cache_dir $file_id $mime_type]
}

proc qc::image_cache_original_exists {cache_dir file_id mime_type} {
    #| Check whether a cache exists of an image at its original dimensions
    if { [qc::image_nsv_cache_original_exists $file_id $mime_type] } {
        return true
    }
    if { [qc::image_filesystem_cache_original_exists ~ {*}{
        cache_dir
        file_id
        mime_type
    }] } {
        return true
    }
    return false
}

proc qc::image_cache_original_data {cache_dir file_id mime_type} {
    #| Dict of image cache data at original dimensions
    #| (file, width, height, url, timestamp)
    #| (empty list if cache does not exist)
    
    if { [qc::image_nsv_cache_original_exists $file_id $mime_type] } {
        return [qc::image_nsv_cache_original_data $file_id $mime_type]
    }
    set data [qc::image_filesystem_cache_original_data ~ {*}{
        cache_dir
        file_id
        mime_type
    }]
    set mime_type [qc::mime_type_guess [dict get $data]]
    qc::image_nsv_cache_original_set $file_id $mime_type $data
    return $data
}

proc qc::image_cache_original_create {cache_dir file_id mime_type} {
    #| Create cache of original image data
    qc::image_filesystem_cache_original_create ~ {*}{
        cache_dir
        file_id
        mime_type
    }
}
