package require sha1
package require md5
package require base64
package require tdom
package require fileutil
package require Trf

namespace eval qc {}

# Private S3 procs
proc qc::_s3_endpoint { args } {
    #| Return an s3 endpoint
    #| Usage:
    #| qc::_s3_endpoint bucket object_key
    #| qc::_s3_endpoint s3_uri
    #| qc::_s3_endpoint bucket

    if { [llength $args] == 1 } {
        if { [qc::is s3_uri [lindex $args 0]] } {
            # qc::_s3_endpoint s3_uri
            lassign [qc::s3 uri_bucket_object_key [lindex $args 0]] bucket object_key
            set object_key_exists true
        } else {
            # qc::_s3_endpoint bucket
            set bucket [lindex $args 0]
            set object_key_exists false
        }
    } elseif { [llength $args] == 2 } {
        # qc::_s3_endpoint bucket object_key
        lassign $args bucket object_key
        set object_key_exists true
    } else {
        error "Invalid number of arguments:\
               Usage: \"qc::_s3_endpoint bucket object_key\"\
               or \"qc::_s3_endpoint s3_uri\"."
    }

    # Use regional endpoint if default region is set - otherwise default to apex domain.
    if { [info exists ::env(AWS_DEFAULT_REGION)] } {
        set endpoint "s3.${::env(AWS_DEFAULT_REGION)}.amazonaws.com"
    } else {
        set endpoint "s3.amazonaws.com"
    }

    if { $bucket ne "" } {
        set endpoint [join [list $bucket $endpoint] .]
    }
    if { $object_key_exists } {
        append endpoint / $object_key
    }
    return $endpoint
}

proc qc::_s3_auth_headers { args } {
    #| Constructs the required s3 authentication header for the request type in question.
    #| See: http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html
    qc::args $args \
        -amz_headers "" \
        -content_type "" \
        -content_md5 "" \
        -- \
        verb \
        object_key \
        bucket

    # check for security token
    if { [info exists ::env(AWS_SESSION_TOKEN)] && $::env(AWS_SESSION_TOKEN) ne "" } {
        # We're using temporary security credentials - add token header
        lappend amz_headers x-amz-security-token $::env(AWS_SESSION_TOKEN)
    }

    set date [qc::format_timestamp_http now]

    if { $bucket ne "" } {
        # Is there a subresource specified?
        set subresources [list "acl" "lifecycle" "location" "logging" "notification" \
                              "partNumber" "policy" "requestPayment" "torrent" \
                              "uploadId" "uploads" "versionId" "versioning" "versions" \
                              "website" "restore"]
        if { [regexp {^[^\?]*\?([A-Za-z]+).*$} $object_key -> resource]
             && [qc::in $subresources $resource] } {
            set canonicalized_resource "/${bucket}/${object_key}"
        } else {
            # otherwise, drop the query part
            set canonicalized_resource "/${bucket}/[qc::url_path $object_key]"
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
            lappend canonicalized_amz_headers \
                "${key}:[join $amz_header_array($key) ,]\u000A"
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
    set signature [::base64::encode [::sha1::hmac \
                                         -bin ${::env(AWS_SECRET_ACCESS_KEY)} \
                                         $string_to_sign]]
    set authorization "AWS ${::env(AWS_ACCESS_KEY_ID)}:$signature"

    set return_headers [list \
                            Host [qc::_s3_endpoint $bucket] \
                            Date $date \
                            Authorization $authorization]

    if { [dict exists $amz_headers "x-amz-security-token"] } {
        lappend return_headers \
            "x-amz-security-token" [dict get $amz_headers "x-amz-security-token"]
    }

    return $return_headers
}

proc qc::_s3_encryption_credentials {} {
    set dict [dict create \
        customer_key [qc::param_get s3_base64_sse_key] \
        customer_key_md5 [qc::_s3_base64_md5 -data [::base64::decode [qc::param_get s3_base64_sse_key]]] \
    ]
    return $dict
}

proc qc::_s3_get { bucket object_key {encrypted false}} {
    #| Construct the http GET request to S3 including auth headers
    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]            
        set headers [_s3_auth_headers -amz_headers $amz_headers GET $object_key $bucket]
        lappend headers {*}$amz_headers
    } else {
        set headers [_s3_auth_headers GET $object_key $bucket]
    }
    set result [qc::http_get \
                    -headers $headers \
                    "https://[qc::_s3_endpoint $bucket $object_key]"]
    return $result
}

proc qc::_s3_exists { bucket object_key {encrypted false} } {
    #| Returns boolean true/false for 200/404 responses, anything else
    #| returns an error.
    set timeout 60
    set url "https://[qc::_s3_endpoint $bucket $object_key]"

    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]
        set headers [_s3_auth_headers -amz_headers $amz_headers HEAD $object_key $bucket]
        lappend headers {*}$amz_headers
    } else {
        set headers [_s3_auth_headers HEAD $object_key $bucket]
    }

    set httpheaders [list]
    foreach {name value} $headers {
	    lappend httpheaders [qc::http_header $name $value]
    }

    dict2vars [qc::http_curl \
                    -nobody 1 \
                    -httpheader $httpheaders \
                    -url $url \
                    -sslverifypeer 0 \
                    -sslverifyhost 0 \
                    -timeout $timeout \
                    -followlocation 1 \
               ] responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    switch $responsecode {
		200 {
		    # OK
		    return true
		}
		404 {
                    return false
                }
		500 {return -code error -errorcode CURL "SERVER ERROR $url"}
		default {
                    return \
                        -code error \
                        -errorcode CURL \
                        "RESPONSE $responsecode while contacting $url"
                }
	    }
	}
	28 {
	    return \
                -code error \
                -errorcode TIMEOUT \
                "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

proc qc::_s3_head { bucket object_key {encrypted false}} {
    #| Construct the http HEAD request to S3 including auth headers
    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]            
        set headers [_s3_auth_headers -amz_headers $amz_headers HEAD $object_key $bucket]
        lappend headers {*}$amz_headers
    } else {
        set headers [_s3_auth_headers HEAD $object_key $bucket]
    }
    
    set result [qc::http_head \
                    -headers $headers \
                    "https://[qc::_s3_endpoint $bucket $object_key]"]
    return $result
}

proc qc::_s3_post { args } {
    #| Construct the http POST request to S3 including auth headers
    qc::args $args \
        -amz_headers "" \
        -content_type {application/xml} \
        -encrypted false \
        -- \
        bucket \
        object_key \
        {data ""}

    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        lappend amz_headers \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256"
    }

    if { $data ne "" } {
        # Used for posting XML
        set content_md5 [qc::_s3_base64_md5 -data $data]
        set headers [_s3_auth_headers \
                         -amz_headers $amz_headers \
                         -content_type $content_type \
                         -content_md5 $content_md5 \
                         POST $object_key $bucket]
        lappend headers Content-MD5 $content_md5
        lappend headers Content-Type $content_type
        lappend headers {*}$amz_headers
        set result [qc::http_post \
                        -valid_response_codes {100 200 202} \
                        -headers $headers \
                        -data $data \
                        "https://[_s3_endpoint $bucket $object_key]"]
    } else {
        if { $amz_headers ne "" } {
            set headers [_s3_auth_headers \
                             -amz_headers $amz_headers \
                             -content_type $content_type \
                             POST $object_key $bucket]
            lappend headers {*}$amz_headers
            lappend headers Content-Type $content_type
            set result [qc::http_post \
                            -headers $headers \
                            "https://[_s3_endpoint $bucket $object_key]"]
        } else {
            set headers [_s3_auth_headers \
                             -content_type $content_type \
                             POST $object_key $bucket]
            lappend headers Content-Type $content_type
            set result [qc::http_post \
                            -headers $headers \
                            "https://[_s3_endpoint $bucket $object_key]"]
        }
    }
    return $result
}

proc qc::_s3_delete { bucket object_key {encrypted false}} {
    #| Construct the http DELETE request to S3 including auth headers
    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]
        set headers [_s3_auth_headers -amz_headers $amz_headers DELETE $object_key $bucket]
        lappend headers {*}$amz_headers
    } else {
        set headers [_s3_auth_headers DELETE $object_key $bucket]
    }
    set result [qc::http_delete \
                    -headers $headers \
                    "https://[_s3_endpoint $bucket $object_key]"]
    return $result
}

proc qc::_s3_save { args } {
    #| Construct the http SAVE request to S3 including auth headers
    qc::args $args -timeout 60 -encrypted false -- bucket object_key filename
    set tmp_file "/tmp/s3-[qc::uuid]"

    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]
        set headers [_s3_auth_headers -amz_headers $amz_headers GET $object_key $bucket]
        lappend headers {*}$amz_headers
    } else {
        set headers [_s3_auth_headers GET $object_key $bucket]
    }
    qc::http_save \
        -timeout $timeout \
        -headers $headers \
        -return_headers_var return_headers \
        "https://[_s3_endpoint $bucket $object_key]" \
        $tmp_file
    if { [dict exists $return_headers x-amz-meta-content-md5] } {
        set base64_md5 [dict get $return_headers x-amz-meta-content-md5]
        if { [qc::_s3_base64_md5 -file $tmp_file] ne $base64_md5 } {
            file delete -force $tmp_file
            error "qc::_s3_save: md5 of downloaded file does not match\
                   x-amz-meta-content-md5 ($base64_md5)."
        }
    } else {
        log Notice "qc::_s3_save: unable to verify downloaded file md5: $filename"
    }
    file copy $tmp_file $filename
    file delete -force $tmp_file
}

proc qc::_s3_put { args } {
    #| Construct the http PUT request to S3 including auth headers
    # _s3_put ?-header 0 ?-infile ? ?-s3_copy ?bucket object_key
    qc::args $args -nochecksum -header 0 -s3_copy ? -infile ? -encrypted false bucket object_key
    set amz_headers [list]
    if { $encrypted } {
        dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
        set amz_headers [list \
            "x-amz-server-side-encryption-customer-key" $customer_key \
            "x-amz-server-side-encryption-customer-key-MD5" $customer_key_md5 \
            "x-amz-server-side-encryption-customer-algorithm" "AES256" \
        ]
    }
    if { [info exists infile]} {
        set content_type [qc::mime_type_guess $infile]
        set content_md5 [qc::_s3_base64_md5 -file $infile]
        set data_size [file size $infile]
        if { [info exists nochecksum] } {
            # Dont send metadata for upload parts
            set headers [_s3_auth_headers \
                             -amz_headers $amz_headers \
                             -content_type $content_type \
                             -content_md5 $content_md5 \
                             PUT $object_key $bucket]
        } else {
            # content_md5 header allows AWS to return an error if the file received
            # has a different md5
            # Authentication value needs to use content_* values for hmac signing
            set headers [_s3_auth_headers \
                             -amz_headers [list "x-amz-meta-content-md5" $content_md5 {*}$amz_headers] \
                             -content_type $content_type \
                             -content_md5 $content_md5 \
                             PUT $object_key $bucket]
            lappend headers x-amz-meta-content-md5 $content_md5
        }
        lappend headers Content-Length $data_size
        lappend headers Content-MD5 $content_md5
        lappend headers Content-Type $content_type
        if { $encrypted } {
            lappend headers {*}$amz_headers
        }
        # Stop tclcurl from stending Transfer-Encoding header
        lappend headers Transfer-Encoding {}
        lappend headers Expect {}
        # Have timeout values roughly in proportion to the filesize
        # In this case allowing 10 KB/s
        set timeout [expr {$data_size/10240}]
        return [qc::http_put \
                    -header $header \
                    -headers $headers \
                    -timeout $timeout \
                    -infile $infile \
                    "https://[_s3_endpoint $bucket $object_key]"]
    } elseif { [info exists s3_copy] } {
        # s3_copy must be in the format "bucket/object_key"
        # we're copying a S3 file - skip the data processing and send the PUT
        # request with x-amz-copy-source header
        if { $encrypted } {
            dict2vars [qc::_s3_encryption_credentials] customer_key customer_key_md5
            lappend amz_headers \
                "x-amz-copy-source-server-side-encryption-customer-key" $customer_key \
                "x-amz-copy-source-server-side-encryption-customer-key-MD5" $customer_key_md5 \
                "x-amz-copy-source-server-side-encryption-customer-algorithm" "AES256" \
        }
        set headers [_s3_auth_headers \
                         -content_type {} \
                         -amz_headers [list "x-amz-copy-source" $s3_copy {*}$amz_headers] \
                         PUT $object_key $bucket]
        lappend headers x-amz-copy-source $s3_copy
        lappend headers Content-Type {}
        if { $encrypted } {
            lappend headers {*}$amz_headers
        }
        return [qc::http_put \
                    -header $header \
                    -headers $headers \
                    -data {} \
                    "https://[_s3_endpoint $bucket $object_key]"]
    } else {
        error "qc::_s3_put: 1 of -infile or -s3_copy must be specified"
    }

}

proc qc::_s3_base64_md5 { args } {
    qc::args $args -file ? -data ? --
    #| Returns the base64 encoded binary md5 digest of a file or data
    if { [info exists file] && [info exists data] } {
        error "qc::_s3_base64_md5: specify only 1 of -file or -data"
    }
    if { [info exists data] } {
        # Just use ::md5 since we don't process chunks of data large enough to
        # cause problems
        return [::base64::encode [::md5::md5 $data]]
    } elseif {[info exists file]} {
        return [::base64::encode [::md5::md5 -file $file]]
    } else {
        error "qc::_s3_base64_md5: 1 of -file or -data must be specified"
    }
}
