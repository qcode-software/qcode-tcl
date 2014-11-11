
namespace eval qc {
    namespace export db_file_* file_upload plupload.html
}



proc qc::db_file_insert {args} {
    #| Insert a file into the file db table
    args $args -employee_id ? -filename ? -mime_type ? -- file_path

    if { ![info exists employee_id] } {
        set employee_id [auth]
    }
    default filename [file tail $file_path]

    if { ! [info exists mime_type] } {
        set mime_type [ns_guesstype $filename]
    }
   
    set id [open $file_path r]
    fconfigure $id -translation binary
    set data [base64::encode [read $id]]
    close $id

    set file_id [db_seq file_id_seq]
    set qry {
	insert into file 
	(file_id,employee_id,filename,data,mime_type)
	values 
	(:file_id,:employee_id,:filename,decode(:data, 'base64'),:mime_type)
    }
    db_dml $qry
    return $file_id

}

proc qc::db_file_copy {file_id} {
    #| Make a copy of this file
    set new_file_id [db_seq file_id_seq]
    db_dml {
        insert into file 
        (file_id,employee_id,filename,data)
	select :new_file_id,employee_id,filename,data
        from file where file_id=:file_id
    }
    return $new_file_id
}

proc qc::db_file_export {args} {
    # Export a file in the db file table to a tmp local file
    args $args -tmp_file ? -- file_id

    default tmp_file /tmp/[uuid::uuid generate]
    db_1row {select filename, encode(data,'base64') as base64 from file where file_id=:file_id}
    set id [open $tmp_file w]
    fconfigure $id -translation binary
    puts $id [base64::decode $base64]
    close $id
    return $tmp_file
}

proc qc::db_file_thumbnailer {file_id {max_width ""} {max_height ""}} {
    #| Return image file resized to the given width and height.
    # Generated thumbnails are cached.
    db_0or1row {
	select filename, upload_date::timestamp(0) as file_created 
	from file where file_id=:file_id
    } {
        # File not found
        error "File file_id:\"$file_id\" not found" {} NOT_FOUND
    }
    set mime_type [ns_guesstype $filename]
    set headers [ns_conn headers]

    set outputheaders [ns_conn outputheaders]
    ns_set put $outputheaders "Last-Modified" [format_timestamp_http [cast_epoch $file_created]]

    set if_modified_since [qc::conn_if_modified_since]
    if { [qc::is_timestamp_http $if_modified_since]
          && [clock scan $if_modified_since] >= [clock scan $file_created] } {
	# Return 304 - Unchanged
	ns_return 304 $mime_type ""

    } else { 
        set base64 [qc::db_file_thumbnail_data $file_id $max_width $max_height]
	set tmp_file /tmp/[uuid::uuid generate]
	set id [open $tmp_file w]
	fconfigure $id -translation binary
        puts $id [base64::decode $base64]
        close $id
	ns_returnfile 200 $mime_type $tmp_file
	file delete $tmp_file
    }
}

proc qc::plupload.html {name chunk chunks file} {
    # Deprecated
    return [db_file_upload $name $chunk $chunks $file]
}

proc qc::db_file_upload {name chunk chunks file {filename ""} {mime_type ""}} {
    #| Upload a file chunk, insert the completed file into the db when complete.
    if { $filename eq "" } {
        set filename $file
    }
    set flags [dict create -filename $filename]
    dict set flags -employee_id [qc::auth]
    if { $mime_type ne "" } {
        dict set flags -mime_type $mime_type
    }
    set tmp_file [qc::file_upload $name $chunk $chunks $file]
    if { $tmp_file ne "" } {
        set file_id [qc::db_file_insert {*}$flags $tmp_file]
        if { [qc::file_is_valid_image $tmp_file] } {
            dict2vars [qc::image_file_info $tmp_file] width height
            db_dml {
                insert into image
                (file_id, width, height)
                values
                (:file_id, :width, :height)
            }
        }
        file delete $tmp_file
        return $file_id
    } else {
        return ""
    }
}

proc qc::db_file_thumbnail_data {file_id {max_width ""} {max_height ""}} {
    #| Returns base64-encoded image resized to the given width and height
    # Generated thumbnails are cached

    if { ! [in [ns_cache_names] images] } {
	ns_cache create images -size [expr 100*1024*1024] 
    }
    if { $max_width ne "" && $max_height ne "" } {
	set key "$file_id $max_width $max_height"
    } else {
	set key $file_id
    }
    if { [ne [ns_cache names images $key] ""] } {
	# NS Cache exists
        return [base64::encode [ns_cache_get images $key]]
    } else {
        if { $max_width eq "" || $max_height eq "" } {
            # Return the original file
            db_1row {
                select encode(data,'base64') as base64
                from file
                where file_id=:file_id
            }
            return $base64
        } else {
            # Check image_cache table
            db_trans {
                # Lock file record to prevent duplicate cache creation
                db_1row {
                    select file_id
                    from file
                    where file_id=:file_id
                    for update
                }
                db_0or1row {
                    select encode(data, 'base64') as base64
                    from image_cache
                    where file_id=:file_id
                    and (
                         (
                          width=:max_width and height<=:max_height
                          )
                         or
                         (
                          width<=:max_width and height=:max_height
                          )
                         )
                } {
                    # Create the thumbnail and cache
                    db_file_thumbnail_cache_create $file_id $max_width $max_height
                    return [base64::encode [ns_cache_get images $key]]
                } {
                    # Store result in ns_cache
                    ns_cache set images $key [base64::decode $base64]
                    return $base64
                }
            }
        }
    }
}

proc qc::db_file_thumbnail_dimensions {file_id max_width max_height} {
    #| Return the actual width and height (as [list $width $height]) of an image thumbnail,
    #| based on the file_id, max_width and max_height
    # Creates a cached thumbnail if it doesn't already exist.
    db_trans {
        # Lock file record to prevent duplicate cache creation
        db_1row {
            select file_id
            from file
            where file_id=:file_id
            for update
        }
        db_0or1row {
            select width, height
            from image_cache
            where file_id=:file_id
            and (
                 (
                  width=:max_width and height<=:max_height
                  )
                 or
                 (
                  width<=:max_width and height=:max_height
                  )
                 )
        } {
            set cache_id [db_file_thumbnail_cache_create $file_id $max_width $max_height]
            db_1row {
                select width, height
                from image_cache
                where cache_id=:cache_id
            }
        }
    }
    return [list $width $height]
}

proc qc::db_file_thumbnail_cache_create {file_id max_width max_height} {
    #| Create a cached thumbnail of an image, return the cache_id
    # ONLY WORKS ON JPEGS AND PNGS -
    # TO DO - SUPPORT FOR OTHER IMAGE FORMATS
    if { ! [in [ns_cache_names] images] } {
	ns_cache create images -size [expr 100*1024*1024] 
    }
    set key "$file_id $max_width $max_height"

    set tmp_file [qc::db_file_export $file_id]
    set thumb /tmp/[uuid::uuid generate]
    # Call imagemagick convert 
    exec_proxy -timeout 10000 -ignorestderr convert -quiet -thumbnail ${max_width}x${max_height} -strip -quality 75% $tmp_file $thumb
    file delete $tmp_file
    set id [open $thumb r]
    fconfigure $id -translation binary
    set data [read $id]
    close $id

    if { [jpeg::isJPEG $thumb] } {
        lassign [jpeg::dimensions $thumb] width height
    } elseif { [png::isPNG $thumb] } {
        qc::dict2vars [png::imageInfo $thumb] width height
    } else {
        file delete $thumb
        error "Unrecognised image type"
    }

    file delete $thumb
    ns_cache set images $key $data
    set base64 [base64::encode $data]
    set cache_id [db_seq image_cache_id_seq]
    db_dml {
        insert into image_cache
        (cache_id, file_id, width, height, data)
        values
        (:cache_id, :file_id, :width, :height, decode(:base64, 'base64'));
    }
    return $cache_id
}
