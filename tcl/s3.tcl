package require sha1
package require md5
package require base64
package require tdom
package require fileutil
namespace eval qc {
    namespace export s3
}

# Deprecated.
# See qc::aws s3
# Public S3 procs
proc qc::s3 { args } {
    #| Access Amazon S3 buckets via REST API
    # Usage: s3 subcommand {args}

    if { (![info exists ::env(AWS_ACCESS_KEY_ID)] || ![info exists ::env(AWS_SECRET_ACCESS_KEY)]) &&
         [lindex $args 0] ni [list "md5" "uri" "uri_bucket_object_key"] } {
        error "No AWS credentials set."
    }

    switch [lindex $args 0] {
        md5 {
            #| Just print the base64 md5 of a local file for reference
            # usage: s3 md5 filename
            lassign $args -> filename 
            return [qc::_s3_base64_md5 -file $filename]
        }
        ls {
            # usage: s3 ls 
            set nodes [qc::s3_xml_select [qc::_s3_get "" ""] {/ns:ListAllMyBucketsResult/ns:Buckets/ns:Bucket}]
            return [qc::lapply qc::s3_xml_node2dict $nodes]
        }
        lsbucket {
            # usage: s3 lsbucket bucket {prefix}
            # s3 lsbucket myBucket Photos/
            if { [llength $args] == 1 || [llength $args] > 3 } {
                error "Missing argument. Usage: qc::s3 lsbucket mybucket {prefix}"
            } elseif { [llength $args] == 3 }  {
                # prefix is specified
                set xmlDoc [qc::_s3_get [lindex $args 1] "?prefix=[lindex $args 2]"]
            } else {
                set xmlDoc [qc::_s3_get [lindex $args 1] ""]
            }
	    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select $xmlDoc {/ns:ListBucketResult/ns:Contents}]]
        }
        get {
            # usage:
            # qc::s3 get bucket remote_filename {local_filename}
            # qc::s3 get s3_uri local_filename
            if { [llength $args] < 3 || [llength $args] > 4 } {
                error "Wrong number of arguments. Usage: \"qc::s3 get mybucket remote_filename ?local_filename?\" or \"qc::s3 get s3_uri local_filename\"."
            } elseif { [llength $args] == 3 } {
                # Test if args are $bucket and $remote_filename or $s3_uri and $local_filename
                lassign $args -> arg0 arg1
                if { [qc::is s3_uri $arg0] } {
                    # qc::s3 get s3_uri local_filename
                    set s3_uri $arg0
                    lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    set local_filename $arg1
                } else {
                    # qc::s3 get bucket remote_filename
                    set bucket $arg0
                    # Strip the starting "/" from the remote_filename
                    set object_key [string range $arg1 1 end]
                    set s3_uri [qc::s3 uri $bucket $object_key]
                    # No local filename, assume same as remote_filename
                    set local_filename "./[file tail $remote_filename]"
                }
            } else {
                # qc::s3 get bucket remote_filename {local_filename}
                lassign $args -> bucket remote_filename local_filename
                set object_key [string range $remote_filename 1 end]
                set s3_uri [qc::s3 uri $bucket $object_key]
            }
            if { [file exists $local_filename] } {
                error "File $local_filename already exists."
            }
            set head_dict [qc::s3 head $s3_uri]
            set file_size [dict get $head_dict Content-Length]
            # set timeout - allow 1Mb/s
            set timeout_secs [expr {max( (${file_size}*8)/1000000 , 60)} ]
            log Debug "Timeout set at $timeout_secs seconds"
            qc::_s3_save -timeout $timeout_secs $bucket $object_key $local_filename
        }
        exists {
            # usage:
            # qc::s3 exists bucket remote_path
            # qc::s3 exists s3_uri
            if { [llength $args] == 3 } {
                # qc::s3 exists bucket remote_path
                lassign $args -> bucket remote_path
                set object_key [string range $remote_path 1 end]
            } elseif { [llength $args] == 2 } {
                # qc::s3 exists s3_uri
                set s3_uri [qc::cast s3_uri [lindex $args 1]]
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "qc::s3 exists: Wrong number of args. Usage \"qc::s3 exists bucket remote_path\" or \"qc::s3 head s3_uri\"."
            }
            qc::_s3_exists $bucket $object_key

        }
        head {
            # usage:
            # qc::s3 head bucket remote_path
            # qc::s3 head s3_uri

            if { [llength $args] == 3 } {
                # qc::s3 head bucket remote_path
                lassign $args -> bucket remote_path
                set object_key [string range $remote_path 1 end]
            } elseif { [llength $args] == 2 } {
                # qc::s3 head s3_uri
                set s3_uri [qc::cast s3_uri [lindex $args 1]]
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "qc::s3 head: Wrong number of args. Usage \"qc::s3 head bucket remote_path\" or \"qc::s3 head s3_uri\"."
            }

            qc::_s3_head $bucket $object_key
        }       
        copy {
            # usage:
            # qc::s3 copy bucket remote_filename_to_copy remote_filename_copy
            # E.G. qc::s3 copy "my-bucket" "file_to_copy" "file_copy"
            # qc::s3 copy s3_uri_to_copy s3_uri_copy

            if {[llength $args] == 4} {
                # qc::s3 copy bucket remote_filename_to_copy remote_filename_copy
                lassign $args -> bucket remote_filename remote_filename_copy
                set file_to_copy "${bucket}${remote_filename}"
                set object_key_copy [string range $remote_filename_copy 1 end]
            } elseif {[llength $args] == 3} {
                # qc::s3 copy s3_uri_to_copy s3_uri_copy
                lassign $args -> s3_uri_to_copy s3_uri_copy
                lassign [qc::s3 uri_bucket_object_key $s3_uri_to_copy] bucket object_key
                set file_to_copy "${bucket}/${object_key}"
                lassign [qc::s3 uri_bucket_object_key $s3_uri_copy] bucket_to object_key_copy
                if { $bucket ne $bucket_to } {
                    error "qc::s3 copy: The s3_uri to copy to must be in the same bucket as the s3_uri to copy from."
                }
            } else {
                error "qc::s3 copy: Wrong number of args. Usage \"qc::s3 copy bucket remote_filename_to_copy remote_filename_copy\" or \"qc::s3 copy s3_uri_to_copy s3_uri_copy\"."
            }

            qc::_s3_put -s3_copy $file_to_copy $bucket $object_key_copy
        }
        put {
            # usage:
            # qc::s3 put bucket local_path ?remote_filename?
            # qc::s3 put s3_uri local_filename
            # 5MB limit
            if { [llength $args] < 3 || [llength $args] > 4 } {
                error "Wrong number of arguments. Usage: \"qc::s3 put mybucket local_filename ?remote_filename?\" or \"qc::s3 put s3_uri local_filename\"."
            } elseif { [llength $args] == 3 } {
                # Test if args are $bucket and $remote_filename or $s3_uri and $local_filename
                lassign $args -> arg0 arg1
                if { [qc::is s3_uri $arg0] } {
                    # qc::s3 put s3_uri local_filename
                    set s3_uri $arg0
                    lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    set local_filename $arg1
                } else {
                    # qc::s3 put bucket local_path
                    set bucket $arg0
                    set local_filename $arg1
                    # No remote filename, assume same as local_filename
                    set object_key [file tail $local_filename]
                    set s3_uri [qc::s3 uri $bucket $object_key]
                }
            } else {
                # qc::s3 put bucket local_path remote_filename
                lassign $args -> bucket local_filename remote_filename
                set object_key [string range $remote_filename 1 end]
                set s3_uri [qc::s3 uri $bucket $object_key]
            }

            if { [file size $local_filename] > [expr {1024*1024*5}]} { 
                # Use multipart upload
                qc::s3 upload $s3_uri $local_filename
            } else {
                qc::_s3_put -infile $local_filename $bucket $object_key
            }
        }
        restore {
            # usage:
            # qc::s3 restore bucket remote_path days
            # qc::s3 restore s3_uri Days
            # Requests restore of object from Glacier storage to S3 storage for $days days
            lassign $args -> bucket remote_path Days
            if { [llength $args] == 4  } {
                 # qc::s3 restore bucket remote_path days
                lassign $args -> bucket remote_path Days
                set object_key [string range $remote_path 1 end]
            } elseif { [llength $args] == 3 } {
                # qc::s3 restore s3_uri Days
                lassign $args -> s3_uri Days
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "Invalid number of arguments. Usage: \"qc::s3 restore bucket remote_path days\" or \"qc::s3 restore s3_uri days\"."
            }
            set data "<RestoreRequest>[qc::xml_from Days]</RestoreRequest>"
            qc::_s3_post $bucket "${object_key}?restore" $data
        }
        upload {
            switch [lindex $args 1] {
                init {
                    # Usage:
                    # qc::s3 upload init bucket local_file remote_file {content_type}
                    # qc::s3 upload init s3_uri local_file {content_type}

                    set content_type ""
                    if { [llength $args] == 6 } {
                        # qc::s3 upload init bucket local_file remote_file content_type
                        lassign $args -> -> bucket local_file remote_file content_type
                        set object_key [string range $remote_file 1 end]
                    } elseif { [llength $args] == 5 } {
                        lassign $args -> -> arg0 local_file arg1
                        if { [qc::is s3_uri $arg0] } {
                            # qc::s3 upload init s3_uri local_file content_type
                            set s3_uri $arg0
                            lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                            set content_type $arg1
                        } else {
                            # qc::s3 upload init bucket local_file remote_file
                            set bucket $arg0
                            set remote_file $arg1
                            set object_key [string range $remote_file 1 end]
                        }
                    } elseif { [llength $args] == 4 } {
                        # qc::s3 upload init s3_uri local_file
                        lassign $args -> -> s3_uri local_file
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload init bucket local_file remote_file {content_type}\" or \"qc::s3 upload init s3_uri local_file {content_type}\"."
                    }
                    
                    set content_md5 [qc::_s3_base64_md5 -file $local_file]
                    if {$content_type eq ""} {
                        set content_type [qc::mime_type_guess $local_file]
                    }
                    set upload_dict [qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_post -content_type $content_type -amz_headers [list x-amz-meta-content-md5 $content_md5] $bucket "${object_key}?uploads"] {/ns:InitiateMultipartUploadResult}]]
                    set upload_id [dict get $upload_dict UploadId]
                    log Debug "Upload init for $object_key to $bucket."
                    log Debug "Upload_id: $upload_id"
                    return $upload_id
                }
                abort {
                    # Usage:
                    # qc::s3 upload abort bucket remote_path upload_id
                    # qc::s3 upload abort s3_uri upload_id
                    if {[llength $args] == 5 } {
                        # qc::s3 upload abort bucket remote_path upload_id
                        lassign $args -> -> bucket remote_path upload_id
                        set object_key [string range $remote_path 1 end]
                    } elseif {[llength $args] == 4 } {
                        # qc::s3 upload abort s3_uri upload_id
                        lassign $args -> -> s3_uri upload_id
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload abort bucket remote_path upload_id\" or \"qc::s3 upload abort s3_uri upload_id\"."
                    }
                    return [_s3_delete $bucket "${object_key}?uploadId=$upload_id"]
                }
                ls {
                    # usage: s3 upload ls bucket 
                    lassign $args -> -> bucket
                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_get $bucket "?uploads"] {/ns:ListMultipartUploadsResult/ns:Upload}]]
                }
                lsparts {
                    # usage:
                    # qc::s3 upload lsparts bucket remote_path upload_id
                    # qc::s3 upload lsparts s3_uri upload_id
                    if {[llength $args] == 5 } {
                        # qc::s3 upload lsparts bucket remote_path upload_id
                        lassign $args -> -> bucket remote_path upload_id
                        set object_key [string range $remote_path 1 end]
                    } elseif {[llength $args] == 4 } {
                        # qc::s3 upload lsparts s3_uri upload_id
                        lassign $args -> -> s3_uri upload_id
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload lsparts bucket remote_path upload_id\" or \"qc::s3 upload lsparts s3_uri upload_id\"."
                    }
                    
                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_get $bucket "${object_key}?uploadId=$upload_id"] {/ns:ListPartsResult/ns:Part}]]
                }
                cleanup {
                    # usage: s3 upload cleanup bucket 
                    # aborts any unfinished uploads for bucket
                    lassign $args -> -> bucket 
                    foreach dict [qc::s3 upload ls $bucket] {
                        qc::s3 upload abort $bucket "/[dict get $dict Key]" [dict get $dict UploadId]
                    }
                }
                complete {
                    # usage:
                    # qc::s3 upload complete bucket remote_path upload_id etag_dict
                    # qc::s3 upload complete s3_uri upload_id etag_dict
                    if {[llength $args] == 6} {
                        # qc::s3 upload complete bucket remote_path upload_id etag_dict
                        lassign $args -> -> bucket remote_path upload_id etag_dict
                        set object_key [string range $remote_path 1 end]
                    } elseif {[llength $args] == 5} {
                        # qc::s3 upload complete s3_uri upload_id etag_dict
                        lassign $args -> -> s3_uri upload_id etag_dict
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload complete bucket remote_path upload_id etag_dict\" or \"qc::s3 upload complete s3_uri upload_id etag_dict\"."
                    }
                    set xml {<CompleteMultipartUpload>}
                    foreach PartNumber [dict keys $etag_dict] {
                        set ETag [dict get $etag_dict $PartNumber]
                        lappend xml "<Part>[qc::xml_from PartNumber ETag]</Part>"
                    }
                    lappend xml {</CompleteMultipartUpload>}
                    log Debug "Completing Upload to $object_key in $bucket."
                    return [qc::_s3_post $bucket "${object_key}?uploadId=$upload_id" [join $xml \n]]
                }
                send {
                    # Perform upload
                    # usage:
                    # qc::s3 upload send bucket local_path remote_path upload_id
                    # qc::s3 upload send s3_uri local_path upload_id
                    if {[llength $args] == 6} {
                        # qc::s3 upload send bucket local_path remote_path upload_id
                        lassign $args -> -> bucket local_path remote_path upload_id
                        set object_key [string range $remote_path 1 end]
                    } elseif {[llength $args] == 5} {
                        # qc::s3 upload send s3_uri local_path upload_id
                        lassign $args -> -> s3_uri local_path upload_id
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload send bucket local_path remote_path upload_id\" or \"qc::s3 upload send s3_uri local_path upload_id\"."
                    }
                    
                    # bytes
                    set part_size [expr {1024*1024*5}]
                    set part_index 1
                    set etag_dict [dict create]
                    set file_size [file size $local_path]
                    # Timeout - allow 10 KB/s
                    global s3_timeout
                    set s3_timeout($upload_id) false
                    # Set timeout based on file size, but don't make it less than 10,000ms
                    set timeout_ms [expr { max(round((double($file_size)/10240)*1000),10000) }]
                    set max_attempt 10
                    log Debug "Timeout set as $timeout_ms ms"
                    set id [after $timeout_ms [list set s3_timeout($upload_id) true]]
                    set num_parts [expr {round(ceil($file_size/double($part_size)))}]
                    set fh [open $local_path r]
                    fconfigure $fh -translation binary
                    while { !$s3_timeout($upload_id) &&  $part_index <= $num_parts } {

                        # Use temp file to upload part from - inefficient, but posting binary data directly from http_put not yet working.
                        set tempfile [::fileutil::tempfile]
                        set tempfh [open $tempfile w]
                        fconfigure $tempfh -translation binary
                        log Debug "Uploading ${local_path}: Sending part $part_index of $num_parts"
                        puts -nonewline $tempfh [read $fh $part_size]
                        close $tempfh

                        set success false 
                        set attempt 1
                        while { !$s3_timeout($upload_id) && $attempt<=$max_attempt && !$success } {
                            try {
                                set response [qc::_s3_put -header 1 -nochecksum -infile $tempfile $bucket "${object_key}?partNumber=${part_index}&uploadId=$upload_id"]
                                set success true
                            } {
                                log Debug "Failed - retrying part $part_index of ${num_parts}... "
                                incr attempt
                            }
                        }

                        if { $s3_timeout($upload_id) || $attempt>$max_attempt } {
                            #TODO should we abort or leave for potential recovery later?
                            ::try {
                                qc::s3 upload abort $bucket $object_key $upload_id
                            } on error [list error_message options] {
                                # error when attempting to abort upload; do nothing
                            }

                            set message "Failed to upload file to bucket $bucket."

                            if { $s3_timeout($upload_id) } {
                                append message " Upload timed out."
                            }

                            if { $attempt > $max_attempt } {
                                append message " Number of attempts exceeded max attempts (${max_attempt})."
                            }

                            error $message
                        }
                        regexp -line -- {^ETag: "(\S+)"\s*$} $response match etag
                        
                        dict set etag_dict $part_index $etag
                        file delete $tempfile
                        incr part_index
                    }
                    close $fh
                    after cancel $id
                    unset s3_timeout($upload_id)
                    return $etag_dict

                }
                default {
                    # Top level multipart upload
                    # usage:
                    # qc::s3 upload bucket local_file remote_file {content_type}
                    # qc::s3 upload s3_uri local_file {content_type}
                    # TODO could be extended to retry upload part failures
                    set content_type ""
                    if {[llength $args] == 5} {
                        # qc::s3 upload bucket local_file remote_file content_type
                        lassign $args -> bucket local_file remote_file content_type
                        set object_key [string range $remote_file 1 end]
                    } elseif {[llength $args] == 4} {
                        lassign $args -> arg0 local_file arg1
                        if { [qc::is s3_uri $arg0] } {
                            # qc::s3 upload s3_uri local_file content_type
                            set s3_uri $arg0
                            lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                            set content_type $arg1
                        } else {
                            # qc::s3 upload bucket local_file remote_file
                            set bucket $arg0
                            set remote_file $arg1
                            set object_key [string range $remote_file 1 end]
                            set content_type ""
                        }
                    } elseif {[llength $args] == 3} {
                        # qc::s3 upload s3_uri local_file
                        lassign $args -> s3_uri local_file
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                        set content_type ""
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload bucket local_file remote_file {content_type}\" or \"qc::s3 upload s3_uri local_file {content_type}\"."
                    }
                    
                    set upload_id [qc::s3 upload init [qc::s3 uri $bucket $object_key] $local_file $content_type]
                    set etag_dict [qc::s3 upload send [qc::s3 uri $bucket $object_key] $local_file $upload_id]
                    qc::s3 upload complete [qc::s3 uri $bucket $object_key] $upload_id $etag_dict
                }
            }
        }
        delete {
            # usage:
            # qc::s3 delete bucket remote_file
            # qc::s3 delete s3_uri
            if {[llength $args] == 3} {
                # qc::s3 delete bucket remote_file
                lassign $args -> bucket remote_file
                set object_key [string range $remote_file 1 end]
            } elseif {[llength $args] == 2} {
                # qc::s3 delete s3_uri
                lassign $args -> s3_uri
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "Invalid number of arguments. Usage: \"qc::s3 delete bucket remote_filename\" or \"qc::s3 delete s3_uri\"."
            }
            
            qc::_s3_delete $bucket $object_key
        }
        uri {
            #| Return an s3_uri in the format s3://bucket/object_key
            # Usage:
            # qc::s3 uri bucket ?object_key?
            if {[llength $args] < 2 || [llength $args] > 3} {
                error "Invalid number of arguments. Usage: \"qc::s3 uri bucket ?object_key?\"."
            }
            lassign $args -> bucket object_key
            return [qc::cast s3_uri "${bucket}/${object_key}"]
        }
        uri_bucket_object_key {
            #| Return a list of the bucket and object key for the given s3_uri
            #| Usage:
            #| qc::s3 uri_bucket_object_key s3_uri
            if {[llength $args] != 2} {
                error "Invalid number of arguments. Usage: \"qc::s3 uri_bucket_object_key s3_uri\"."
            }
            regexp {^(?:[sS]3://|/)?([^/]+)/?(.*)} [lindex $args 1] -> bucket object_key
            return [list $bucket $object_key]
        }
        default {
            error "Unknown s3 command \"$args\""
        }
    }
}
