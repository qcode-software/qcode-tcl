namespace eval qc {
    namespace export \
        aws_metadata \
        aws_metadata_get \
        aws_metadata_token_refresh \
}

proc qc::aws_metadata { category } {
    #| Simple wrapper which queries AWS instance metadata for the requested category
    # eg. a request for 
    # http://169.254.169.254/latest/meta-data/placement/availability-zone
    # would become
    # qc::aws_metadata placement/availability-zone
    # See http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
    # for a full list of cetegories supported.

    # Token init
    if { ![info exists ::env(AWS_METADATA_TOKEN)] } {
        qc::aws_metadata_token_refresh ::env(AWS_METADATA_TOKEN)
    }

    # Get cached token
    set token $::env(AWS_METADATA_TOKEN)

    ::try {
        return [qc::aws_metadata_get $token $category]
    } trap {IMDSV2_TOKEN_EXPIRED} {} {
        set token [qc::aws_metadata_token_refresh ::env(AWS_METADATA_TOKEN)]
        # Retry
        return [qc::aws_metadata_get $token $category]
    }
}

proc qc::aws_metadata_get { token category } {
    #| Get IMDS request
    set result [qc::http_get \
            -headers [list "X-aws-ec2-metadata-token" $token] \
            -noproxy \
            -response_code true \
            -valid_response_codes [list 200 401] \
            http://169.254.169.254/latest/meta-data/$category \
        ]
    set http_response_code [dict get $result code]
    if { $http_response_code == 401 } {
        # expired token
        error "IMDSv2 token expired." {} {IMDSV2_TOKEN_EXPIRED}
    }
    return [dict get $result body]
}

proc qc::aws_metadata_token_refresh { token_cache } {
    #| Refresh and cache metadata token
    qc::log Notice "qc::aws_metadata_token_refresh on cache $token_cache"
    set token [qc::http_put \
                -data "" \
                -headers [list X-aws-ec2-metadata-token-ttl-seconds 21600] \
                http://169.254.169.254/latest/api/token \
              ]
    set $token_cache $token
    return $token
}
