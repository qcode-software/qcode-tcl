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

    proc http_get { s3_uri query_params } {
        #| Makes http GET request (including auth headers) to 
        #| S3 API endpoint and returns result.
        set headers [_http_headers \
                        GET \
                        $s3_uri \
                        $query_params \
                        ]
        set url [_endpoint $s3_uri $query_params]
        set result [qc::http_get \
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

    proc _http_headers { args} {
        #| Returns HTTP headers required for REST API auth.
        #TODO Calls legacy version. To be migrated here in future.
        qc::args $args \
            -amz_headers "" \
            -content_type "" \
            -content_md5 "" \
            -- http_verb s3_uri query_params
         _credentials_check

        dict2vars [qc::aws s3 s3_uri_parse $s3_uri] bucket object_key
        set query_string [qc::url_make [dict create params $query_params]]
        return [qc::_s3_auth_headers \
            -amz_headers $amz_headers \
            -content_type $content_type \
            -content_md5 $content_md5 \
            -- \
            $http_verb "${object_key}${query_string}" $bucket \
            ]
    }

    proc _endpoint { s3_uri query_params } {
        #| Returns REST API endpoint.
        #| https://mybucket.s3.eu-west-1.amazonaws.com/object_key/?prefix=folder1
        dict2vars [qc::aws s3 s3_uri_parse $s3_uri] . object_key
        
        return [qc::url \
            "https://[_endpoint_domain $s3_uri]/:object_key" \
            object_key $object_key \
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

