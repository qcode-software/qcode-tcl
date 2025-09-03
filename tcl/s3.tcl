package require sha1
package require md5
package require base64
package require tdom
package require fileutil
namespace eval qc {
    namespace export s3
}

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
            # qc::s3 get s3_uri local_filename
            if { [llength $args] == 3 } {
                lassign $args -> arg0 arg1                
                set s3_uri $arg0
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                set local_filename $arg1                
            } else {
                error "Wrong number of arguments. Usage: \"qc::s3 get s3_uri local_filename\"."
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

            if { $file_size != [file size $local_filename] } {
                set local_file_size [file size $local_filename]
                file delete -force $local_filename
                error "qc::s3 get: size of downloaded file ($local_file_size) $local_filename does not match expected $file_size of $s3_uri"
            }
        }
        exists {
            # usage:
            # qc::s3 exists s3_uri
            if { [llength $args] == 2 } {
                set s3_uri [qc::cast s3_uri [lindex $args 1]]
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "qc::s3 exists: Wrong number of args. Usage \"qc::s3 exists s3_uri\"."
            }
            qc::_s3_exists $bucket $object_key
        }
        head {
            # usage:
            # qc::s3 head s3_uri

            if { [llength $args] == 2 } {
                set s3_uri [qc::cast s3_uri [lindex $args 1]]
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "qc::s3 head: Wrong number of args. Usage \"qc::s3 head s3_uri\"."
            }

            qc::_s3_head $bucket $object_key
        }       
        copy {
            # usage:
            # qc::s3 copy s3_uri_from s3_uri_to

            if {[llength $args] == 3} {
                lassign $args -> s3_uri_to_copy s3_uri_copy
                lassign [qc::s3 uri_bucket_object_key $s3_uri_to_copy] bucket object_key
                set file_to_copy "${bucket}/${object_key}"
                lassign [qc::s3 uri_bucket_object_key $s3_uri_copy] bucket_to object_key_copy
                if { $bucket ne $bucket_to } {
                    error "qc::s3 copy: The s3_uri to copy to must be in the same bucket as the s3_uri to copy from."
                }
            } else {
                error "qc::s3 copy: Wrong number of args. Usage \"qc::s3 copy s3_uri_from s3_uri_to\"."
            }

            qc::_s3_put -s3_copy $file_to_copy $bucket $object_key_copy
        }
        put {
            # usage:
            # qc::s3 put s3_uri local_filename {encrypted false}
            # 5MB limit
            if { [llength $args] == 4 } {
                lassign $args -> arg0 arg1 arg2
                set s3_uri $arg0
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                set local_filename $arg1
                if { [qc::castable boolean $arg2] } {
                    set encrypted $arg2
                } else {
                    set encrypted false
                }
            } elseif { [llength $args] == 3 } {
                lassign $args -> arg0 arg1                
                set s3_uri $arg0
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                set local_filename $arg1                
                set encrypted false
            } else {
                error "Wrong number of arguments. Usage: \"qc::s3 put s3_uri local_filename\"."
            }

            if { [file size $local_filename] > [expr {1024*1024*5}]} { 
                # Use multipart upload
                qc::s3 upload $s3_uri $local_filename $encrypted
            } else {
                qc::_s3_put -encrypted $encrypted -infile $local_filename $bucket $object_key
            }
        }
        restore {
            # usage:
            # qc::s3 restore s3_uri Days
            # Requests restore of object from Glacier storage to S3 storage for $days days
            if { [llength $args] == 3 } {
                lassign $args -> s3_uri Days
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "Invalid number of arguments. Usage: \"qc::s3 restore s3_uri days\"."
            }
            set data "<RestoreRequest>[qc::xml_from Days]</RestoreRequest>"
            qc::_s3_post $bucket "${object_key}?restore" $data
        }
        upload {
            switch [lindex $args 1] {
                init {
                    # Usage:
                    # qc::s3 upload init s3_uri local_file encrypted

                    set content_type ""
                    if { [llength $args] == 5 } {
                        lassign $args -> -> s3_uri local_file encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload init s3_uri local_file encrypted\"."
                    }
                    
                    set content_md5 [qc::_s3_base64_md5 -file $local_file]
                    set content_type [qc::mime_type_guess $local_file]

                    set upload_dict [qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_post -encrypted $encrypted -content_type $content_type -amz_headers [list x-amz-meta-content-md5 $content_md5] $bucket "${object_key}?uploads"] {/ns:InitiateMultipartUploadResult}]]
                    set upload_id [dict get $upload_dict UploadId]
                    log Debug "Upload init for $object_key to $bucket."
                    log Debug "Upload_id: $upload_id"
                    return $upload_id
                }
                abort {
                    # Usage:
                    # qc::s3 upload abort s3_uri upload_id encrypted
                    if {[llength $args] == 5 } {
                        lassign $args -> -> s3_uri upload_id encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload abort s3_uri upload_id encrypted\"."
                    }
                    return [_s3_delete $bucket "${object_key}?uploadId=$upload_id" $encrypted]
                }
                ls {
                    # usage: s3 upload ls bucket encrypted
                    lassign $args -> -> bucket encrypted
                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_get $bucket "?uploads" $encrypted] {/ns:ListMultipartUploadsResult/ns:Upload}]]
                }
                lsparts {
                    # usage:
                    # qc::s3 upload lsparts s3_uri upload_id encrypted
                    if {[llength $args] == 5 } {
                        lassign $args -> -> s3_uri upload_id encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload lsparts s3_uri upload_id encrypted\"."
                    }

                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::_s3_get $bucket "${object_key}?uploadId=$upload_id" $encrypted] {/ns:ListPartsResult/ns:Part}]]
                }
                cleanup {
                    # usage: s3 upload cleanup bucket encrypted
                    # aborts any unfinished uploads for bucket
                    lassign $args -> -> bucket encrypted
                    foreach dict [qc::s3 upload ls $bucket $encrypted] {
                        set s3_uri [qc::s3 uri $bucket [dict get $dict Key]]
                        qc::s3 upload abort $s3_uri [dict get $dict UploadId] $encrypted
                    }
                }
                complete {
                    # usage:
                    # qc::s3 upload complete s3_uri upload_id etag_dict encrypted
                    if {[llength $args] == 6} {
                        lassign $args -> -> s3_uri upload_id etag_dict encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload complete s3_uri upload_id etag_dict encrypted\"."
                    }
                    set xml {<CompleteMultipartUpload>}
                    foreach PartNumber [dict keys $etag_dict] {
                        set ETag [dict get $etag_dict $PartNumber]
                        lappend xml "<Part>[qc::xml_from PartNumber ETag]</Part>"
                    }
                    lappend xml {</CompleteMultipartUpload>}
                    log Debug "Completing Upload to $object_key in $bucket."
                    return [qc::_s3_post -encrypted $encrypted $bucket "${object_key}?uploadId=$upload_id" [join $xml \n]]
                }
                send {
                    # Perform upload
                    # usage:
                    # qc::s3 upload send s3_uri local_path upload_id encrypted
                    if {[llength $args] == 6} {
                        lassign $args -> -> s3_uri local_path upload_id encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload send s3_uri local_path upload_id encrypted\"."
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
                                set response [qc::_s3_put -encrypted $encrypted -header 1 -nochecksum -infile $tempfile $bucket "${object_key}?partNumber=${part_index}&uploadId=$upload_id"]
                                set success true
                            } {
                                log Debug "Failed - retrying part $part_index of ${num_parts}... "
                                incr attempt
                            }
                        }

                        if { $s3_timeout($upload_id) || $attempt>$max_attempt } {
                            #TODO should we abort or leave for potential recovery later?
                            ::try {
                                qc::s3 upload abort [qc::s3 uri $bucket $object_key] $upload_id $encrypted
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
                    # qc::s3 upload s3_uri local_file {encrypted false}
                    # TODO could be extended to retry upload part failures
                    if { [llength $args] == 4 } {
                        lassign $args -> s3_uri local_file encrypted
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                        if { [qc::castable boolean $encrypted] } {
                            set encrypted $encrypted
                        } else {
                            set encrypted false
                        }
                    } elseif { [llength $args] == 3 } {
                        lassign $args -> s3_uri local_file
                        lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
                        set encrypted false
                    } else {
                        error "Invalid number of arguments. Usage: \"qc::s3 upload s3_uri local_file\"."
                    }

                    set upload_id [qc::s3 upload init [qc::s3 uri $bucket $object_key] $local_file $encrypted]
                    set etag_dict [qc::s3 upload send [qc::s3 uri $bucket $object_key] $local_file $upload_id $encrypted]
                    qc::s3 upload complete [qc::s3 uri $bucket $object_key] $upload_id $etag_dict $encrypted
                }
            }
        }
        delete {
            # usage:
            # qc::s3 delete s3_uri
            if {[llength $args] == 2} {
                lassign $args -> s3_uri
                lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
            } else {
                error "Invalid number of arguments. Usage: \"qc::s3 delete s3_uri\"."
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
