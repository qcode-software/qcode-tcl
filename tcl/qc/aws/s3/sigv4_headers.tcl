namespace eval qc::aws {
    namespace export s3
    namespace ensemble create
}

namespace eval qc::aws::s3 {
    namespace export sigv4_headers
    namespace ensemble create

    proc sigv4_headers {
        credentials
        region
        request
    } {
        #| SigV4 headers for AWS requests.
        #| See: https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html

        package require sha256

        qc::dict2vars $credentials {*}{
            access_key_id
            secret_access_key
        }

        qc::dict2vars $request {*}{
            headers
            http_verb
            url
            payload
        }

        set payload_hash [::sha2::sha256 -hex $payload]
        lappend headers "x-amz-content-sha256" $payload_hash

        # Date formats for the signature.
        if { [dict exists $headers "X-Amz-Date"] } {
            set date_string [dict get $headers "X-Amz-Date"]
        } elseif { [dict exists $headers "Date"] } {
            set date_string [dict get $headers "Date"]
        } else {
            error "A \"Date\" or \"X-Amz-Date\" header is required in the request."
        }

        set date_epoch [clock scan $date_string]
        set date [clock format $date_epoch \
            -format "%Y%m%d" \
            -timezone "UTC"]
        set datetime_iso8601 [clock format $date_epoch \
            -format "%Y%m%dT%H%M%SZ"\
            -timezone "UTC"]

        set credential_scope "${date}/${region}/s3/aws4_request"
        set signed_headers [_header_names_signed [dict keys $headers]]

        # Canonical request.
        set url_parts [qc::url_parts $url]
        set path [dict get $url_parts path]
        set params [dict get $url_parts params]
        set lcanonical_request [list $http_verb]
        lappend lcanonical_request [_uri_path_canonicalize $path]
        lappend lcanonical_request [_query_string_canonicalize $params]
        lappend lcanonical_request [_headers_canonicalize $headers]
        lappend lcanonical_request $signed_headers
        lappend lcanonical_request $payload_hash
        set canonical_request [join $lcanonical_request "\n"]

        # String to be signed.
        set parts [list \
            "AWS4-HMAC-SHA256" \
            $datetime_iso8601 \
            $credential_scope \
            [::sha2::sha256 -hex $canonical_request]]
        set string_to_sign [join $parts "\n"]

        # Signature.
        set date_key [::sha2::hmac -bin -key "AWS4$secret_access_key" $date]
        set date_region_key [::sha2::hmac -bin -key $date_key $region]
        set date_region_service_key [::sha2::hmac -bin -key $date_region_key s3]
        set signing_key [::sha2::hmac -bin -key $date_region_service_key "aws4_request"]
        set signature [::sha2::hmac -bin -key $signing_key $string_to_sign]
        set signature [binary encode hex $signature]

        # Authorization header.
        set auth_header "AWS4-HMAC-SHA256 "
        append auth_header "Credential=${access_key_id}/${credential_scope},"
        append auth_header "SignedHeaders=${signed_headers},"
        append auth_header "Signature=${signature}"

        set sigv4_headers [dict create \
            "Authorization" $auth_header \
            "x-amz-content-sha256" $payload_hash]

        return $sigv4_headers
    }

    proc _uri_path_canonicalize {path} {
        #| Canonicalize the URI path for an AWS signed request.

        set parts [split [string trim $path "/"] "/"]
        set decoded [qc::lapply qc::url_decode $parts]
        set encoded [qc::lapply qc::aws::s3::_uri_encode $decoded]

        return "/[join $encoded "/"]"
    }

    proc _query_string_canonicalize {params} {
        #| Canonicalize the query params for an AWS signed request.

        set encoded_pairs [list]

        foreach {name value} $params {
            lappend encoded_pairs \
                [qc::aws::s3::_uri_encode [qc::url_decode $name]] \
                [qc::aws::s3::_uri_encode [qc::url_decode $value]]
        }

        set sorted_pairs [lsort -stride 2 $encoded_pairs]
        set queries [list]

        foreach {name value} $sorted_pairs {
            lappend queries "${name}=${value}"
        }

        return [join $queries "&"]
    }

    proc _headers_canonicalize {headers} {
        #| Canonicalize the headers for an AWS signed request.

        set dict [dict create]

        foreach {name value} $headers {
            set lower_name [string tolower $name]
            regsub -all {\s+} [string trim $value] " " new_value

            if { [dict exists $dict $lower_name] } {
                set existing_value [dict get $dict $lower_name]
                dict set dict $lower_name "${existing_value},${new_value}"
            } else {
                dict set dict $lower_name $new_value
            }
        }

        set sorted [lsort -stride 2 $dict]
        set canonical_headers [list]

        foreach {name value} $sorted {
            lappend canonical_headers "${name}:${value}"
        }

        return "[join $canonical_headers "\n"]\n"
    }

    proc _header_names_signed {header_names} {
        #| Returns signed header names for an AWS signed request.

        set lower_names [lmap name [qc::lunique $header_names] \
            {string tolower $name}]
        return [join [lsort $lower_names] ";"]
    }

    proc _uri_encode {string} {
        #| URI encode a string according to AWS signed request requirements.

        variable ::qc::aws::s3::_uri_encode_map

        if { ! [info exists ::qc::aws::s3::_uri_encode_map] } { 
            qc::aws::s3::_uri_encode_map_init
        }

        return [string map \
            $::qc::aws::s3::_uri_encode_map \
            [encoding convertto "utf-8" $string]]
    }

    proc _uri_encode_map_init {} {
        #| Initialize the URI encode map for AWS URIs.

        variable ::qc::aws::s3::_uri_encode_map [list]

        for {set i 0} {$i < 256} {incr i} {
            set char [format %c $i]
            set hex %[format %02X $i]

            if { ! [string match {[-a-zA-Z0-9.~_]} $char] } {
                lappend ::qc::aws::s3::_uri_encode_map $char $hex
            }
        }
    }
}