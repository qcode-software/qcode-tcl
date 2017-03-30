namespace eval qc {
    namespace export {*}{
        image_autocrop_data
        image_cache_autocrop_exists
        image_cache_autocrop_data
        image_cache_autocrop_create
    }
}

proc qc::image_autocrop_data {cache_dir file_id} {
    #| Dict of autocropped image cache data at original dimensions,
    #| create if needed
    #| (file, width, height, url, timestamp)
    if { ! [qc::image_cache_original_autocrop_exists $cache_dir $file_id] } {
        qc::image_cache_original_autocrop_create $cache_dir $file_id
    }
    return [qc::image_cache_original_autocrop_data $cache_dir $file_id]
}

proc qc::image_cache_autocrop_exists {cache_dir file_id} {
    #| Check if cache exists of autocropped image at original dimensions
    set nsv_key "$file_id original autocrop"
    if { [nsv_exists image_cache_data $nsv_key] } {
        return true
    }
    set glob_pattern "autocrop/${file_id}.*"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    if { [llength [glob {*}$glob_options {*}$glob_pattern]] == 1 } {
        return true
    } else {
        return false
    }
}

proc qc::image_cache_autocrop_data {cache_dir file_id} {
    #| Dict of autocropped image cache data at original dimensions
    #| (file, width, height, url, timestamp)
    #| (empty list if cache does not exist)
    set nsv_key "$file_id original autocrop"
    if { [nsv_exists image_cache_data $nsv_key] } {
        return [nsv_get image_cache_data $nsv_key]
    }
    set glob_pattern "autocrop/${file_id}.*"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set links [glob {*}$glob_options {*}$glob_pattern]
    set file_relative [file link [lindex $links 0]]
    set file_root_relative [string range $file_relative 3 end]
    set file ${cache_dir}/$file_root_relative

    set expression {^/image/[0-9]+/autocrop/([0-9]+)x([0-9]+)/}
    set url [qc::file2url $file]
    regexp $expression $url -> width height
    set timestamp [qc::cast timestamp [file mtime $file]]
    set data [dict_from file width height url timestamp]
    nsv_set image_cache_data $nsv_key $data
    return $data
}

proc qc::image_cache_autocrop_create {cache_dir file_id} {
    #| Create image cache, autocropped, from original dimensions
    #| Create symbolic link to cached image
    set original [qc::image_original_data $cache_dir $file_id]
    set original_file [dict get $original file]
    set ext [file extension $original_file]
    set file [qc::image_file_autocrop $original_file]
    dict2vars [qc::image_file_info $file] width height
    if { $width < [dict get $original width]
         || $height < [dict get $original height]
     } {
        set cache_file_root_relative \
            ${file_id}/autocrop/${width}x${height}/${file_id}${ext}
        set cache_file ${cache_dir}/${cache_file_root_relative}
        file mkdir [file dirname $cache_file]     
        file rename -force $file $cache_file
    } else {
        set cache_file_root_relative \
            [string range [dict get $original url] 1 end]
        set cache_file ${cache_dir}/${cache_file_root_relative}
        file delete $file
    }
    file mkdir ${cache_dir}/autocrop
    file link \
        ${cache_dir}/autocrop/${file_id}${ext} \
        ../$cache_file_root_relative
}