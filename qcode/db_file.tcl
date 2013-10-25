package provide qcode 2.0
namespace eval qc {}

doc qc::db_file {
    Title {Database file storage}
}

proc qc::db_file_insert {args} {
    #| Insert a file into the file db table
    args $args -employee_id ? -mime_type ? -filename ? -- tmp_file

    default employee_id [auth]
    default filename [file tail $tmp_file]
    default mime_type [mime_type_guess [file tail $tmp_file]]
   
    set file_id [db_seq file_id_seq]
    set qry {
	insert into file 
	(file_id,employee_id,filename,data)
	values 
	(:file_id,:employee_id,:filename,[sql_file_data $tmp_file])
    }
    db_dml $qry
    file delete $tmp_file
    return $file_id
}

proc qc::db_file_export {file_id} {
    # Export a file in the db file table to a tmp local file
    db_file_1row {select [sql_file_name -as tmp_file -- data] from file where file_id=:file_id}
    return $tmp_file
}

proc qc::db_file_thumbnailer {file_id {width ""} {height ""}} {
    #| Return image file resized to the given width and height.
    # Generated thumbnails are cached.
    
    # Create the image cache if it doesn't exist yet
    if { ! [in [ns_cache_names] images] } {
	ns_cache create images -size [expr 100*1024*1024] 
    }
    db_1row {
	select filename, upload_date::timestamp(0) as file_created 
	from file where file_id=:file_id
    }
    set mime_type [ns_guesstype $filename]
    set headers [ns_conn headers]
    if { [ns_set find $headers If-Modified-Since]!=-1 } {
	set if_modified_since [ns_set iget $headers If-Modified-Since]
    }   
    if { $width ne "" && $height ne "" } {
	set key "$file_id $width $height"
    } else {
	set key $file_id
    }
    if { [info exists if_modified_since] && [clock scan $if_modified_since]>=[clock scan $file_created] } {
	# Return 304 - Unchanged
	ns_return 304 $mime_type ""
    } elseif { [ne [ns_cache names images $key] ""] } {
	# NS Cache exists
	set tmp_file /tmp/[uuid::uuid generate]
	set id [open $tmp_file a+]
	fconfigure $id -translation binary
	puts $id [ns_cache get images $key]
	close $id
	ns_returnfile 200 $mime_type $tmp_file
	file delete $tmp_file
    } else {
	if { $width ne "" && $height ne "" } {
            db_file_0or1row {
                select
                cache_id,
                [sql_file_name -as tmp_file -- data]
                from image_cache
                where file_id=:file_id
                and width=:width
                and height=:height
            } {
                # Resize and cache
                set tmp_file [qc::db_file_export $file_id]
                set thumb /tmp/[uuid::uuid generate]
                # Call imagemagick convert 
                exec_proxy -timeout 10000 convert -thumbnail ${width}x${height} $tmp_file $thumb
                file delete $tmp_file
                set id [open $thumb r]
                fconfigure $id -translation binary
                set data [read $id]
                close $id
                ns_cache set images $key $data
                set cache_id [db_seq image_cache_id_seq]
                db_dml {
                    insert into image_cache
                    (cache_id, file_id, width, height, data)
                    values
                    (:cache_id, :file_id, :width, :height, decode(:data, 'base64'));
                }
                ns_returnfile 200 $mime_type $thumb
                file delete $thumb
            } {
                ns_returnfile 200 $mime_type $tmp_file
                db_dml {
                    update image_cache
                    set last_accessed=now()
                    where cache_id=:cache_id
                }
                file delete $tmp_file
            }
	} else {
	    # Return original file
            set tmp_file [qc::db_file_export $file_id]
	    ns_returnfile 200 $mime_type $tmp_file
	    file delete $tmp_file
	}
    }
}

proc qc::plupload.html {name chunk chunks file} {
    # Keeps uploaded file parts sent by plupload and concat them once all parts have been sent.
    # File inserted into file table.
    set user_id [qc::auth]
    set id $name
    set tmp_file /tmp/$id.$chunk
    # Move the AOLserver generated tmp file to one we will keep
    file rename [ns_getformfile file] $tmp_file
    if { [nsv_exists pluploads $user_id] } {
	set dict [nsv_get pluploads $user_id]
    } else {
	set dict {}
    }
    dict set dict $id $chunk $tmp_file
    dict set dict $id chunks $chunks
    dict set dict $id filename $file

    set complete true
    foreach chunk [.. 0 $chunks-1] {
	if { ![dict exists $dict $id $chunk] } {
	    set complete false
	    break
	} else {
	    lappend files /tmp/$id.$chunk
	}
    }
    if { $complete } {
	# Join parts together
	exec_proxy cat {*}$files > /tmp/$id
	set file_id [qc::db_file_insert -employee_id $user_id -filename [dict get $dict $id filename] /tmp/$id]
	# Clean up
	foreach file $files {
	    file delete $file
	}
	dict unset dict $id
	return $file_id	
    } else {
	nsv_set pluploads $user_id $dict
	return ""
    }
}

proc db_file_1row {args} {
    args $args -db DEFAULT -- qry
    set table [db_file_select_table -db $db $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

proc db_file_0or1row {args} {
    args $args -db DEFAULT -- qry {no_rows_code ""} {one_row_code ""}
    set table [db_file_select_table -db $db $qry 1]
    set db_nrows [expr {[llength $table]-1}]

    if {$db_nrows==0} {
	# no rows
	set code [ catch { uplevel 1 $no_rows_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } elseif { $db_nrows==1 } { 
	# 1 row
	foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
	set code [ catch { uplevel 1 $one_row_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } else {
	# more than 1 row
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
}

proc db_file_select_table {args} {
    args $args -db DEFAULT -- qry {level 0}
    incr level
    set table [db_select_table -db $db -- $qry $level]
    set col_index 0
    foreach column [lindex $table 0] {
        if { [regexp {^base64_([a-zA-Z0-9_]+)$} $column > fieldname] } {
            lset table 0 $col_index $fieldname
            set row_index 1
            foreach row [lrange $table 1 end] {
                set base64 [lindex $row $col_index]
                if { $base64 ne "" } {
                    set tmp_file /tmp/[uuid::uuid generate]
                    set id [open $tmp_file a+]
                    fconfigure $id -translation binary
                    puts $id [base64::decode $base64]
                    close $id
                    lset table $row_index $col_index $tmp_file
                }
                incr row_index
            }
        }
        incr col_index
    }
    return $table
}

proc sql_file_name {args} {
    args $args -as ? -- fieldname
    default as $fieldname
    if { [regexp {[^a-zA-Z0-9_]} $fieldname] || [regexp {[^a-zA-Z0-9_]} $as] } {
        error "sql_file_name does not support non-alphanumeric fieldnames"
    }
    return "encode($fieldname, 'base64') as base64_$as"
}

proc sql_file_data {filename} {
    set id [open $filename r]
    fconfigure $id -translation binary
    set data [base64::encode [read $id]]
    close $id
    return "decode([db_quote $data],'base64')"
}