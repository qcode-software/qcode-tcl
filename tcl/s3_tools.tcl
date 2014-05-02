
package require sha1
package require md5
package require base64
package require tdom
package require fileutil
namespace eval qc {
    namespace export s3 s3_* aws_*
}

proc qc::aws_credentials_set { access_key secret_key } {
    #| Set globals containing AWS credentials
    set ::env(AWS_ACCESS_KEY_ID) $access_key
    set ::env(AWS_SECRET_ACCESS_KEY) $secret_key
    return true
}

proc qc::aws_region_set { region } {
    #| Set global containing AWS region
    set ::env(AWS_DEFAULT_REGION) $region
    return true
}

proc qc::s3_url { {bucket ""} } {
    lappend bucket "s3.amazonaws.com"
    return [join $bucket "."]
}

proc qc::s3_auth_headers { args } {
    #| Constructs the required s3 authentication header for the request type in question.
    #| See: http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html
    qc::args $args -amz_headers "" -content_type "" -content_md5 "" -- verb path bucket 
    # eg s3_auth_headers -content_type image/jpeg -content_md5 xxxxxx PUT /pics/image.jpg mybucket
    
    set date [qc::format_timestamp_http now]
   
    if { $bucket ne "" } {
        # Is there a subresource specified?
        set subresources [list "acl" "lifecycle" "location" "logging" "notification" "partNumber" "policy" "requestPayment" "torrent" "uploadId" "uploads" "versionId" "versioning" "versions" "website" "restore"]
        if { [regexp {^[^\?]+\?([A-Za-z]+).*$} $path -> resource] && [qc::in $subresources $resource] } {
            set canonicalized_resource "/${bucket}${path}"
        } else {
            # otherwise, drop the query part
            set canonicalized_resource "/$bucket[qc::url_path $path]"
        }
    } else {
        set canonicalized_resource "/"
    }

    # amz_headers format {header value header value ...}
    if { $amz_headers eq "" } {
        set canonicalized_amz_headers  ""
    } else {
        foreach {header value} $amz_headers {
            if { [info exists amz_header_array([qc::lower $header])] } {
                lappend amz_header_array([qc::lower $header]) $value
            } else {
                set amz_header_array([qc::lower $header]) $value
            }
        }
        set canonicalized_amz_headers  ""
        foreach key [lsort [array names amz_header_array]] {
            lappend canonicalized_amz_headers "${key}:[join $amz_header_array($key) ,]\u000A"
        }
        set canonicalized_amz_headers [join $canonicalized_amz_headers ""]
    }

    # Contruct string for hmac signing
    set string_to_sign "$verb"
    lappend string_to_sign "$content_md5"  
    lappend string_to_sign "$content_type"  
    lappend string_to_sign "$date"
    lappend string_to_sign "${canonicalized_amz_headers}${canonicalized_resource}"
    set string_to_sign [join $string_to_sign \n]
    set signature [::base64::encode [::sha1::hmac -bin ${::env(AWS_SECRET_ACCESS_KEY)} $string_to_sign]]
    set authorization "AWS ${::env(AWS_ACCESS_KEY_ID)}:$signature"

    return [list Host [s3_url $bucket] Date $date Authorization $authorization]
}

proc qc::s3_get { bucket path } {
    #| Construct the http GET request to S3 including auth headers
    set headers [s3_auth_headers GET $path $bucket] 
    set result [qc::http_get -headers $headers [s3_url $bucket]$path]
    return $result
}

proc qc::s3_head { bucket path } {
    #| Construct the http HEAD request to S3 including auth headers
    set headers [s3_auth_headers HEAD $path $bucket] 
    set result [qc::http_head -headers $headers [s3_url $bucket]$path]
    return $result
}

proc qc::s3_post { args } {
    qc::args $args -amz_headers "" -content_type {application/xml} -- bucket path {data ""}
    #| Construct the http POST request to S3 including auth headers
    if { $data ne "" } {
        # Used for posting XML
        set content_md5 [qc::s3_base64_md5 -data $data]
        set headers [s3_auth_headers -content_type $content_type -content_md5 $content_md5 POST $path $bucket] 
        lappend headers Content-MD5 $content_md5
        lappend headers Content-Type $content_type
        set result [qc::http_post -valid_response_codes {100 200 202} -headers $headers -data $data [s3_url $bucket]$path]
    } else {
        if { $amz_headers ne "" } {
            set headers [s3_auth_headers -amz_headers $amz_headers -content_type $content_type POST $path $bucket] 
            lappend headers {*}$amz_headers
            lappend headers Content-Type $content_type
            set result [qc::http_post -headers $headers [s3_url $bucket]$path]
        } else {
            set headers [s3_auth_headers -content_type $content_type POST $path $bucket] 
            lappend headers Content-Type $content_type
            set result [qc::http_post -headers $headers [s3_url $bucket]$path]
        }
    }
    return $result
}

proc qc::s3_delete { bucket path } {
    #| Construct the http DELETE request to S3 including auth headers
    set headers [s3_auth_headers DELETE $path $bucket] 
    set result [qc::http_delete -headers $headers [s3_url $bucket]$path]
    return $result
}

proc qc::s3_save { args } {
    #| Construct the http SAVE request to S3 including auth headers
    qc::args $args -timeout 60 -- bucket path filename
    set headers [s3_auth_headers GET $path $bucket] 
    return [qc::http_save -timeout  $timeout -headers $headers [s3_url $bucket]$path $filename]
}

proc qc::s3_put { args } {
    #| Construct the http PUT request to S3 including auth headers
    # s3_put ?-header 0 ?-infile ? ?-s3_copy ?bucket path 
    qc::args $args -nochecksum -header 0 -s3_copy ? -infile ? bucket path
    if { [info exists infile]} {
        set content_type [qc::mime_type_guess $infile]
        set content_md5 [qc::s3_base64_md5 -file $infile]
        set data_size [file size $infile]
        if { [info exists nochecksum] } {
            # Dont send metadata for upload parts
            set headers [s3_auth_headers -content_type $content_type -content_md5 $content_md5 PUT $path $bucket] 
        } else {
            # content_md5 header allows AWS to return an error if the file received has a different md5
            # Authentication value needs to use content_* values for hmac signing
            set headers [s3_auth_headers -amz_headers [list "x-amz-meta-content-md5" $content_md5] -content_type $content_type -content_md5 $content_md5 PUT $path $bucket] 
            lappend headers x-amz-meta-content-md5 $content_md5
        }
        lappend headers Content-Length $data_size
        lappend headers Content-MD5 $content_md5
        lappend headers Content-Type $content_type
        # Stop tclcurl from stending Transfer-Encoding header
        lappend headers Transfer-Encoding {}
        lappend headers Expect {}
        # Have timeout values roughly in proportion to the filesize
        # In this case allowing 10 KB/s
        set timeout [expr {$data_size/10240}]
        return [qc::http_put -header $header -headers $headers -timeout $timeout -infile $infile [s3_url $bucket]$path]
    } elseif { [info exists s3_copy] } {
        # we're copying a S3 file - skip the data processing and send the PUT request with x-amz-copy-source header
        set headers [s3_auth_headers -content_type {} -amz_headers [list "x-amz-copy-source" $s3_copy] PUT $path $bucket]
        lappend headers x-amz-copy-source $s3_copy
        lappend headers Content-Type {}
        return [qc::http_put -header $header -headers $headers -data {} [s3_url $bucket]$path]
    } else {
        error "qc::s3_put: 1 of -infile or -s3_copy must be specified"
    }

}

proc qc::s3_base64_md5 { args } {
    qc::args $args -file ? -data ? -- 
    #| Returns the base64 encoded binary md5 digest of a file or data
    if { [info exists file] && [info exists data] } {
        error "qc::s3_base64_md5: specify only 1 of -file or -data"
    }
    if { [info exists data] } {
        # Just use ::md5 since we don't process chunks of data large enough to cause problems
        return [::base64::encode [::md5::md5 $data]]
    } elseif {[info exists file]} {
        # Will not use ::md5 if Trf isn't installed due to incorrect results & long runtimes for large files
        if { [qc::in [package names] "Trf"] } {
            return [::base64::encode [::md5::md5 -file $file]]
        } else {
            set openssl [exec which openssl] 
            return [exec $openssl dgst -md5 -binary $file | $openssl enc -base64]
        }
    } else {
        error "qc::s3_base64_md5: 1 of -file or -data must be specified"
    }
}

proc qc::s3 { args } {
    #| Access Amazon S3 buckets via REST API
    # Usage: s3 subcommand {args}

    if { ![info exists ::env(AWS_ACCESS_KEY_ID)] || ![info exists ::env(AWS_SECRET_ACCESS_KEY)] } {
        error "No AWS credentials set."
    }

    switch [lindex $args 0] {
        md5 {
            #| Just print the base64 md5 of a local file for reference
            # usage: s3 md5 filename
            lassign $args -> filename 
            return [qc::s3_base64_md5 -file $filename]
        }
        ls {
            # usage: s3 ls 
            set nodes [qc::s3_xml_select [qc::s3_get "" /] {/ns:ListAllMyBucketsResult/ns:Buckets/ns:Bucket}]
            return [qc::lapply qc::s3_xml_node2dict $nodes]
        }
        lsbucket {
            # usage: s3 lsbucket bucket {prefix}
            # s3 lsbucket myBucket Photos/
            if { [llength $args] == 1 || [llength $args] > 3 } {
                error "Missing argument. Usage: qc::s3 lsbucket mybucket {prefix}"
            } elseif { [llength $args] == 3 }  {
                # prefix is specified
                set xmlDoc [qc::s3_get [lindex $args 1] "/?prefix=[lindex $args 2]"]
            } else {
                set xmlDoc [qc::s3_get [lindex $args 1] /]
            }
	    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select $xmlDoc {/ns:ListBucketResult/ns:Contents}]]
        }
        get {
            # usage: s3 get bucket remote_filename local_filename
            if { [llength $args] < 3 || [llength $args] > 4 } {
                error "Wrong number of arguments. Usage: qc::s3 get mybucket remote_filename {local_filename}"
            } elseif { [llength $args] == 3 } {
                # No local filename, assume same as remote_filename in current directory
                lassign $args -> bucket remote_filename 
                set local_filename "./[file tail $remote_filename]"
            } else {
                lassign $args -> bucket remote_filename local_filename
            }
            if { [file exists $local_filename] } {
                error "File $local_filename already exists."
            }
            set head_dict [qc::s3 head $bucket $remote_filename]
            if { [dict exists $head_dict x-amz-meta-content-md5] } {
                set base64_md5 [dict get $head_dict x-amz-meta-content-md5]
            }
            set file_size [dict get $head_dict Content-Length]
            # set timeout - allow 1Mb/s
            set timeout_secs [expr {max( (${file_size}*8)/1000000 , 60)} ]
            log Debug "Timeout set at $timeout_secs seconds"
            qc::s3_save -timeout $timeout_secs $bucket $remote_filename $local_filename
            if { [info exists base64_md5] } {
                # Check the base64 md5 of the downloaded file matches what we put in the x-amz-meta-content-md5 metadata on upload
                if { [set local_md5 [qc::s3_base64_md5 -file $local_filename]] ne $base64_md5 } {
                    error "qc::s3 get: md5 of downloaded file $local_filename ($local_md5) does not match x-amz-meta-content-md5 ($base64_md5)."
                }
            }
        }
        head {
            # usage: s3 head bucket remote_path
            qc::s3_head {*}[lrange $args 1 end]
        }       
        copy {
            # usage: s3 copy bucket bucket/remote_filename_to_copy remote_filename_copy
            lassign $args -> bucket remote_filename remote_filename_copy
            qc::s3_put -s3_copy $remote_filename $bucket $remote_filename_copy
        }
        put {
            # usage: s3 put bucket local_path {remote_filename}
            # 5MB limit
            if { [llength $args] < 3 || [llength $args] > 4 } {
                error "Wrong number of arguments. Usage: qc::s3 put mybucket local_filename {remote_filename}"
            } elseif { [llength $args] == 3 } {
                # No remote filename, assume same as local_filename
                lassign $args -> bucket local_filename 
                set remote_filename "/[file tail $local_filename]"
            } else {
                lassign $args -> bucket local_filename remote_filename
            }

            if { [file size $local_filename] > [expr {1024*1024*5}]} { 
                # Use multipart upload
                qc::s3 upload $bucket $local_filename $remote_filename
            } else {
                qc::s3_put -infile $local_filename $bucket $remote_filename
            }
        }
        restore {
            # usage: s3 restore bucket remote_path days
            # Requests restore of object from Glacier storage to S3 storage for $days days
            lassign $args -> bucket remote_path Days
            if { [llength $args] != 4  } {
                error "Invalid number of arguments. Usage: muppet s3 restore bucket remote_path days"
            }
            set data "<RestoreRequest>[qc::xml_from Days]</RestoreRequest>"
            qc::s3_post $bucket ${remote_path}?restore $data
        }
        upload {
            switch [lindex $args 1] {
                init {
                    # s3 upload init bucket local_file remote_file
                    lassign $args -> -> bucket local_file remote_file
                    set content_md5 [qc::s3_base64_md5 -file $local_file]
                    set content_type [qc::mime_type_guess $local_file]
                    set upload_dict [qc::s3_xml_node2dict [qc::s3_xml_select [qc::s3_post -content_type $content_type -amz_headers [list x-amz-meta-content-md5 $content_md5] $bucket ${remote_file}?uploads] {/ns:InitiateMultipartUploadResult}]]
                    set upload_id [dict get $upload_dict UploadId]
                    log Debug "Upload init for $remote_file to $bucket."
                    log Debug "Upload_id: $upload_id"
                    return $upload_id
                }
                abort {
                    # s3 upload abort bucket remote_path upload_id
                    lassign $args -> -> bucket remote_path upload_id
                    return [s3_delete $bucket ${remote_path}?uploadId=$upload_id]
                }
                ls {
                    # usage: s3 upload ls bucket 
                    lassign $args -> -> bucket
                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::s3_get $bucket /?uploads] {/ns:ListMultipartUploadsResult/ns:Upload}]]
                }
                lsparts {
                    # usage: s3 upload lsparts bucket remote_path upload_id
                    lassign $args -> -> bucket remote_path upload_id
                    return [qc::lapply qc::s3_xml_node2dict [qc::s3_xml_select [qc::s3_get $bucket ${remote_path}?uploadId=$upload_id] {/ns:ListPartsResult/ns:Part}]]
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
                    # usage: s3 upload complete bucket remote_path upload_id etag_dict
                    lassign $args -> -> bucket remote_path upload_id etag_dict
                    set xml {<CompleteMultipartUpload>}
                    foreach PartNumber [dict keys $etag_dict] {
                        set ETag [dict get $etag_dict $PartNumber]
                        lappend xml "<Part>[qc::xml_from PartNumber ETag]</Part>"
                    }
                    lappend xml {</CompleteMultipartUpload>}
                    log Debug "Completing Upload to $remote_path in $bucket."
                    return [qc::s3_post $bucket ${remote_path}?uploadId=$upload_id [join $xml \n]]
                }
                send {
                    # Perform upload
                    # usage: s3 upload send bucket local_path remote_path upload_id
                    lassign $args -> -> bucket local_path remote_path upload_id
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
                                set response [qc::s3_put -header 1 -nochecksum -infile $tempfile $bucket ${remote_path}?partNumber=${part_index}&uploadId=$upload_id]
                                set success true
                            } {
                                log Debug "Failed - retrying part $part_index of ${num_parts}... "
                                incr attempt
                            }
                        }
                        if { $s3_timeout($upload_id) || $attempt>$max_attempt } { 
                            #TODO should we abort or leave for potential recovery later?
                            try {
                                qc::s3 upload abort $bucket $remote_path $upload_id
                            }
                            error "Upload timed out"
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
                    # usage: s3 upload bucket local_path remote_path
                    # TODO could be extended to retry upload part failures
                    lassign $args -> bucket local_file remote_file 
                    set upload_id [qc::s3 upload init $bucket $local_file $remote_file]
                    set etag_dict [qc::s3 upload send $bucket $local_file $remote_file $upload_id]
                    qc::s3 upload complete $bucket $remote_file $upload_id $etag_dict
                }
            }
        }
        delete {
            # usage: s3 delete bucket remote_filename
            qc::s3_delete {*}[lrange $args 1 end]
        }
        default {
            error "Unknown s3 command."
        }
    }
}

proc qc::s3_xml_select { xmlDoc xpath} {
    #| Returns xml nodes specified by the supplied xpath.
    # any namespace specified in the xmlns attribute is mapped to "ns" for use in the xpath query.
    set doc [dom parse $xmlDoc]
    set root [$doc documentElement]
    if { [$root hasAttribute xmlns] } {
        $doc selectNodesNamespaces "ns [$root getAttribute xmlns]"
    }
    return [$root selectNodes $xpath] 
}

proc qc::s3_xml_node2dict { node } {
    #| Converts an XML tdom node into a dict.
    # Use qc::s3_xml_select to select suitable nodes with non-repeating elements
    set dict ""
    set nodes [$node childNodes]
    foreach node $nodes {
        if { [llength [$node childNodes]] > 1 \
           || ([llength [$node childNodes]] == 1 \
              && [ne [[$node firstChild] nodeType] TEXT_NODE] ) } {
            lappend dict [$node nodeName] [qc::s3_xml_node2dict $node]
        }  elseif { [llength [$node childNodes]] == 0 } {
            # empty node
            lappend dict [$node nodeName] {}
        } else {
            lappend dict [$node nodeName] [$node asText]
        }
    }
    return $dict
}
