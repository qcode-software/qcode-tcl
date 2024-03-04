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
        qc::args $args \
            -timeout 60 \
            -region "" \
            -- \
            s3_uri \
            query_params

        if { $region eq "" } {
            if { [info exists ::env(AWS_DEFAULT_REGION)] } {
                set region $::env(AWS_DEFAULT_REGION)
            } else {
                error "No region specified."
            }
        }

        set headers [_http_headers \
                        GET \
                        $region \
                        $s3_uri \
                        $query_params \
                        "" \
                        ]
        set url [_endpoint $s3_uri $query_params]
        set result [qc::http_get \
                        -valid_response_codes {200} \
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

    proc _http_headers { args} {
        #| Returns HTTP headers required for REST API auth.
        qc::args $args \
            -- \
            http_verb \
            region \
            s3_uri \
            query_params \
            payload

         _credentials_check

        set headers [dict create \
            Host [_endpoint_domain $s3_uri] \
            X-Amz-Date [clock format [clock scan now] \
                -format "%Y%m%dT%H%M%SZ" \
                -timezone "UTC"]]

        if { [info exists ::env(AWS_SESSION_TOKEN)]
             && $::env(AWS_SESSION_TOKEN) ne "" } {
            # We're using temporary security credentials - add token header
            dict set headers "x-amz-security-token" $::env(AWS_SESSION_TOKEN)
        }

        set credentials [dict create \
            access_key_id $::env(AWS_ACCESS_KEY_ID) \
            secret_access_key $::env(AWS_SECRET_ACCESS_KEY)]
        set request [dict create \
            http_verb $http_verb \
            url [_endpoint $s3_uri $query_params] \
            headers $headers \
            payload $payload]

        set sigv4_headers [qc::aws s3 sigv4_headers \
            $credentials \
            $region \
            $request]

        return [dict merge $headers $sigv4_headers]
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
        # Use regional endpoint if default region is set otherwise default to
        # apex domain.
        if { [info exists ::env(AWS_DEFAULT_REGION)] } {
            lappend temp "s3.${::env(AWS_DEFAULT_REGION)}.amazonaws.com"
        } else {
            lappend temp "s3.amazonaws.com"
        }
        set domain [join $temp "."]
        return $domain
    }
}

