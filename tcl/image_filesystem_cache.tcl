namespace eval qc {
    namespace export {*}{
        image_filesystem_cache_exists
        image_filesystem_cache_data
        image_filesystem_cache_create
        image_filesystem_cache_smaller_biggest_exists
        image_filesystem_cache_glob
        image_filesystem_cache_file2dimensions
        image_filesystem_cache_original_exists
        image_filesystem_cache_original_data
        image_filesystem_cache_original_create
        image_filesystem_cache_autocrop_exists
        image_filesystem_cache_autocrop_data
        image_filesystem_cache_autocrop_create
    }
}

################################################################################
# Filesystem Cache of Image

proc qc::image_filesystem_cache_exists {args} {
    #| Test whether a filesystem cache of an image exists. args:
    #| dict-style of cache_dir, file_id, mime_type, width, height, autocrop
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    # Requested size matches or exceeds full-sized image in cache
    if { [qc::image_filesystem_cache_smaller_biggest_exists {*}$args] } {
        return true
    }

    foreach file [qc::image_filesystem_cache_glob {*}$args] {
        lassign \
            [qc::image_filesystem_cache_file2dimensions $file] \
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

proc qc::image_filesystem_cache_data {args} {
    #| Return filesystem cache data. args:
    #| dict-style of cache_dir, file_id, mime_type, width, height, autocrop
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    # Requested size matches or exceeds full-sized image in cache
    if { [qc::image_filesystem_cache_smaller_biggest_exists {*}$args] } {
        if { $autocrop } {
            set data [qc::image_filesystem_cache_autocrop_data \
                          ~ file_id mime_type cache_dir]
            set mime_type [qc::mime_type_guess [dict get $data file]]
            qc::image_nsv_cache_autocrop_set $file_id $mime_type $data

        } else {
            set data [qc::image_filesystem_cache_original_data \
                        ~ file_id mime_type cache_dir]
            set mime_type [qc::mime_type_guess [dict get $data file]]
            qc::image_nsv_cache_original_set $file_id $mime_type $data
        }
        return $data
    }
    set file_list [qc::image_filesystem_cache_glob {*}$args]

    # Sort files by extension so that non-webp are favoured
    if { $mime_type eq "*/*" } {
        set tmp [list]
        foreach ext {
            .png
            .gif
            .jpg
            .jpeg
            .webp
        } {
            foreach file $file_list {
                if { $ext eq [file extension $file] } {
                    lappend tmp $file
                }
            }
        }
        set file_list $tmp
    }
    
    foreach file $file_list {
        lassign \
            [qc::image_filesystem_cache_file2dimensions $file] \
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
            set timestamp [qc::cast timestamp [file mtime $file]]
            set data [dict_from width height url timestamp]
            set mime_type [qc::mime_type_guess $file]

            qc::image_nsv_cache_set ~ {*}{
                autocrop
                file_id
                mime_type
                data
            }
            return $data
        }
    }

    error "No matching filesystem image data cache exists"
}

proc qc::image_filesystem_cache_create {args} {
    #| Create a file for this image in the disk cache,
    #| constrained to max_width & max_height,
    #| optionally auto-cropped,
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    if { $autocrop } {
        dict2vars [qc::image_autocrop_data $cache_dir $file_id $mime_type] \
            file width height
    } else {
        dict2vars [qc::image_original_data $cache_dir $file_id $mime_type] \
            file width height
    }
    set ext [file extension $file]

    if { $width > $max_width
         || $height > $max_height
     } {
        set file [qc::image_file_resize $file $max_width $max_height]
        dict2vars [qc::image_file_info $file] width height

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
}

proc qc::image_filesystem_cache_smaller_biggest_exists {args} {
    #| Test if a "biggest" (original & autocropped) version of the image
    #| exists in filesystem cache, that is no bigger than the given restrictions
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"

    if { $autocrop } {
        set command_prefix "qc::image_filesystem_cache_autocrop"
    } else {
        set command_prefix "qc::image_filesystem_cache_original"
    }
    
    if { [${command_prefix}_exists ~ cache_dir file_id mime_type] } {
        dict2vars [${command_prefix}_data ~ cache_dir file_id mime_type] \
            width height
        
        if { $width <= $max_width
             && $height <= $max_height
         } {
            return true
        }
    }
    return false
}

proc qc::image_filesystem_cache_glob {args} {
    #| Return a list of files on the filesystem cache that match the given
    #| file_id, and match at least one size constraint exactly
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
        max_width
        max_height
        autocrop
    }
    default mime_type "*/*"
    if { $mime_type eq "*/*" } {
        set ext ".*"
    } else {
        set ext [qc::mime_file_extension $mime_type]
    }
    if { $autocrop } {
        set glob_patterns \
            [list \
                 "${file_id}/autocrop/${max_width}x*/${file_id}${ext}" \
                 "${file_id}/autocrop/*x${max_height}/${file_id}${ext}"]

    } else {
        set glob_patterns \
            [list \
                 "${file_id}-${max_width}x*/${file_id}${ext}" \
                 "${file_id}-*x${max_height}/${file_id}${ext}"]
    }
    
    set data [list]
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set return_data [list]
    return [glob {*}$glob_options {*}$glob_patterns]
}

proc qc::image_filesystem_cache_file2dimensions {file} {
    #| Extract the width and height from a filesystem cache path
    set expression {[^0-9]([0-9]+)x([0-9]+)[^0-9]}
    regexp $expression $file -> width height
    return [list $width $height]
}

################################################################################
# Filesystem Cache of Original Image

proc qc::image_filesystem_cache_original_exists {args} {
    #| Test whether a filesystem cache of the original image file exists
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"
    if { $mime_type eq "*/*" } {
        set ext ".*"
    } else {
        set ext [qc::mime_file_extension $mime_type]
    }    
    set glob_pattern "${file_id}${ext}"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    if { [llength [glob {*}$glob_options {*}$glob_pattern]] == 1 } {
        return true
    } else {
        return false
    }
}

proc qc::image_filesystem_cache_original_data {args} {
    #| Dict of data for the original image, from the filesystem cache
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"
    if { $mime_type eq "*/*" } {
        set ext ".*"
    } else {
        set ext [qc::mime_file_extension $mime_type]
    }
    set glob_pattern "${file_id}${ext}"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set file_list [glob {*}$glob_options {*}$glob_pattern]

    # Sort files by extension so that non-webp are favoured
    if { $mime_type eq "*/*" } {
        set tmp [list]
        foreach ext {
            .png
            .gif
            .jpg
            .jpeg
            .webp
        } {
            foreach file $file_list {
                if { $ext eq [file extension $file] } {
                    lappend tmp $file
                }
            }
        }
        set file_list $tmp
    }
    
    set link [lindex $file_list 0]

    set file_relative [file link $link]
    set file ${cache_dir}/${file_relative}

    lassign [qc::image_filesystem_cache_file2dimensions $file] \
        width height
    set url [qc::file2url $file]
    set timestamp [qc::cast timestamp [file mtime $file]]

    return [dict_from file width height url timestamp]
}

proc qc::image_filesystem_cache_original_create {args} {
    #| Create an cache of an image at its original dimensions, in cache_dir
    #| Create symbolic link to cached image
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"
    db_1row {
        select
        filename,
        mime_type as db_mime_type,
        width,
        height
        
        from file
        join image using(file_id)
        
        where file_id=:file_id
    }
    if { $mime_type ne "*/*"
         && $mime_type ne $db_mime_type
     } {
        set original_typed_file \
            [dict get \
                 [qc::image_cache_original_data \
                      $cache_dir \
                      $file_id \
                      $db_mime_type] \
                 file]
        set cache_file \
            [qc::image_file_convert $original_typed_file $mime_type]
        set ext [file extension $cache_file]
        set cache_file_relative ${file_id}-${width}x${height}/${file_id}${ext}
        
    } else {
        set ext [file extension $filename]
        set cache_file_relative ${file_id}-${width}x${height}/${file_id}${ext}
        set cache_file ${cache_dir}/${cache_file_relative}
        if { ! [file exists $cache_file] } {
            set file [qc::db_file_export $file_id]
            qc::image_file_meta_strip $file
            
            file mkdir [file dirname $cache_file]
            file rename -force $file $cache_file
        }
    }
    file link ${cache_dir}/${file_id}${ext} $cache_file_relative
}

################################################################################
# Filesystem Cache of Autocrop Image

proc qc::image_filesystem_cache_autocrop_exists {args} {
    #| Test whether a filesystem cache of the autocrop image file exists
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"
    if { $mime_type eq "*/*" } {
        set ext ".*"
    } else {
        set ext [qc::mime_file_extension $mime_type]
    }    
    set glob_pattern "autocrop/${file_id}${ext}"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    if { [llength [glob {*}$glob_options {*}$glob_pattern]] == 1 } {
        return true
    } else {
        return false
    }
}

proc qc::image_filesystem_cache_autocrop_data {args} {
    #| Dict of data for the autocrop image, from the filesystem cache
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"
    if { $mime_type eq "*/*" } {
        set ext ".*"
    } else {
        set ext [qc::mime_file_extension $mime_type]
    }    
    set glob_pattern "autocrop/${file_id}${ext}"
    set glob_options [list -nocomplain -types f -directory $cache_dir]
    set file_list [glob {*}$glob_options {*}$glob_pattern]

    # Sort files by extension so that non-webp are favoured
    if { $mime_type eq "*/*" } {
        set tmp [list]
        foreach ext {
            .png
            .gif
            .jpg
            .jpeg
            .webp
        } {
            foreach file $file_list {
                if { $ext eq [file extension $file] } {
                    lappend tmp $file
                }
            }
        }
        set file_list $tmp
    }
    
    set link [lindex $file_list 0]

    set file_relative [file link $link]
    set file_root_relative [string range $file_relative 3 end]
    set file ${cache_dir}/$file_root_relative

    lassign [qc::image_filesystem_cache_file2dimensions $file] \
        width height
    set url [qc::file2url $file]
    set timestamp [qc::cast timestamp [file mtime $file]]

    return [dict_from file width height url timestamp]
}

proc qc::image_filesystem_cache_autocrop_create {args} {
    #| Create image cache, autocropped, from original dimensions
    #| Create symbolic link to cached image
    qc::args2vars $args {*}{
        cache_dir
        file_id
        mime_type
    }
    default mime_type "*/*"

    set original [qc::image_original_data $cache_dir $file_id $mime_type]
    set original_file [dict get $original file]
    set ext [file extension $original_file]

    set file [qc::image_file_autocrop $original_file]

    dict2vars [qc::image_file_info $file] width height

    if { $width < [dict get $original width]
         || $height < [dict get $original height]
     } {
        # Autocropped image is smaller, keep it
        set cache_file_root_relative \
            ${file_id}/autocrop/${width}x${height}/${file_id}${ext}
        set cache_file ${cache_dir}/${cache_file_root_relative}
        file mkdir [file dirname $cache_file]     
        file rename -force $file $cache_file

    } else {
        # Autocroppped image is the same size, discard it and
        # link to original instead.
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
