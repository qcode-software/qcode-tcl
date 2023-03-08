namespace eval qc::aws {
    namespace export s3
    namespace ensemble create
}

namespace eval qc::aws::s3 {
    namespace export rest_api
    namespace ensemble create
}

namespace eval qc::aws::s3::rest_api {
    namespace export http_get
    namespace ensemble create

    proc http_get { args } {
        #| Makes http GET request (including auth headers) to 
        #| S3 API endpoint and returns result.
        qc::args $args -timeout 60 -- s3_uri query_params
        set headers [_http_headers \
                        GET \
                        $s3_uri \
                        $query_params \
                        ]
        set url [_endpoint $s3_uri $query_params]
        set result [qc::http_get \
                        -timeout $timeout \
                        -headers $headers \
                        $url \
                    ]
        return $result
    }

    proc _credentials_check { } {
        #| Check for required AWS credentials in env vars
        if {
            (![info exists ::env(AWS_ACCESS_KEY_ID)] 
        ||   ![info exists ::env(AWS_SECRET_ACCESS_KEY)]) 
        } {
            error "No AWS credentials set."
        }
    }

    proc _http_headers_canonicalized_resource { s3_uri query_params } {
        #| Create a canonical resource to use in request signing 
        dict2vars [qc::aws s3 s3_uri_parse $s3_uri] bucket object_key

        if { $bucket eq "" } {
            return "/"
        }

        # Is there a subresource specified?
        set subresources [list \
                            "acl" "lifecycle" "location" \
                            "logging" "notification" "partNumber" \
                            "policy" "requestPayment" "torrent" \
                            "uploadId" "uploads" "versionId" \
                            "versioning" "versions" "website" \
                            "restore" \
                         ]
        set canonicalized_resource "/${bucket}/${object_key}"
        if { [llength [lintersect $subresources [dict keys $query_params]]] > 0 } {
            set query_string [qc::url_make [dict create params $query_params]]
            append canonicalized_resource ${query_string}
        }
        return $canonicalized_resource
    }
    
    proc _http_headers_canonicalized_amz_headers { headers } {
        #| Create canonical headers to use in request signing
        foreach {header value} $headers {
            if { [info exists header_array([qc::lower $header])] } {
                lappend header_array([qc::lower $header]) $value
            } else {
                set header_array([qc::lower $header]) $value
            }
        }
        set canonicalized_headers  [list]
        foreach key [lsort [array names header_array]] {
            lappend canonicalized_headers "${key}:[join $header_array($key) ,]\u000A"
        }
        return $canonicalized_headers
    }

    proc _http_headers_signature { 
        verb
        content_md5
        content_type
        date
        canonicalized_amz_headers
        canonicalized_resource
    } {
        #| Calculate request signature
        set     temp [list $verb]
        lappend temp "$content_md5"  
        lappend temp "$content_type"  
        lappend temp "$date"
        lappend temp "[join ${canonicalized_amz_headers} ""]${canonicalized_resource}"

        return [::base64::encode \
                    [::sha1::hmac \
                        -bin \
                        ${::env(AWS_SECRET_ACCESS_KEY)} \
                        [join $temp \n] \
                    ] \
                ]
    }

    proc _http_headers { args} {
        #| Returns HTTP headers required for REST API auth.
        qc::args $args \
            -amz_headers "" \
            -content_type "" \
            -content_md5 "" \
            -- http_verb s3_uri query_params

         _credentials_check

        # check for security token
        if { [info exists ::env(AWS_SESSION_TOKEN)] && $::env(AWS_SESSION_TOKEN) ne "" } {
            # We're using temporary security credentials - add token header
            lappend amz_headers x-amz-security-token $::env(AWS_SESSION_TOKEN)
        }

        set date [qc::format_timestamp_http now]
        set canonicalized_resource [_http_headers_canonicalized_resource $s3_uri $query_params]

        # amz_headers format {header value header value ...}
        set canonicalized_amz_headers [_http_headers_canonicalized_amz_headers $amz_headers]


        set signature [_http_headers_signature \
                            $http_verb \
                            $content_md5 \
                            $content_type \
                            $date \
                            $canonicalized_amz_headers \
                            $canonicalized_resource \
                      ]
        # TODO should be signature V4
        set authorization "AWS ${::env(AWS_ACCESS_KEY_ID)}:$signature"

        set request_headers [dict create \
                                Host [_endpoint_domain $s3_uri] \
                                Date $date \
                                Authorization $authorization \
                            ]

        if { [dict exists $amz_headers "x-amz-security-token"] } {
            dict set request_headers \
                "x-amz-security-token" [dict get $amz_headers "x-amz-security-token"] 
        }

        return $request_headers
    }

    proc _endpoint { s3_uri query_params } {
        #| Returns REST API endpoint.
        #| https://mybucket.s3.eu-west-1.amazonaws.com/object_key/?prefix=folder1
        dict2vars [qc::aws s3 s3_uri_parse $s3_uri] . object_key

        set url [list "https://[_endpoint_domain $s3_uri]"]

        # If object_key contains "/" we don't want that url encoded
        set segments [split $object_key "/"]
        set index 0
        set segment_values [list]
        foreach segment $segments {
            lappend segment_values segment_${index} $segment
            set segment_${index} $segment
            lappend url ":segment_${index}"
            incr index
        }

        return [qc::url \
            [join $url "/"] \
            {*}$segment_values \
            {*}$query_params \
            ]
    }

     proc _endpoint_domain { s3_uri } {
        #| Returns full REST API domain.
        #| mybucket.s3.eu-west-1.amazonaws.com
        dict2vars [qc::aws s3 s3_uri_parse $s3_uri] bucket
       
        set temp [list]
        if { $bucket ne "" } {
            lappend temp $bucket
        }
        # Use regional endpoint if default region is set - otherwise default to apex domain.
        if { [info exists ::env(AWS_DEFAULT_REGION)] } {
            lappend temp "s3.${::env(AWS_DEFAULT_REGION)}.amazonaws.com"
        } else {
            lappend temp "s3.amazonaws.com"
        }
        set domain [join $temp "."]
         return $domain
    }
}

