namespace eval qc {
    namespace export \
        aws_metadata \
        aws_credentials_set_from_ec2_role \
        aws_credentials_get_from_ec2_role \
        aws_credentials_set \
        aws_region_set
}

proc qc::aws_metadata { category } {
    #| Simple wrapper which queries AWS instance metadata for the requested category
    # eg. a request for 
    # http://169.254.169.254/latest/meta-data/placement/availability-zone
    # would become
    # qc::aws_metadata placement/availability-zone
    # See http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
    # for a full list of cetegories supported.
    set token_cache ::env(AWS_METADATA_TOKEN)
    set token [qc::_aws_metadata_token $token_cache]
    ::try {
        return [qc::_aws_metadata_get $token $category]
    } trap {IMDSV2_TOKEN_EXPIRED} {} {
        set token [qc::_aws_metadata_token_refresh $token_cache]
        # Retry
        return [qc::_aws_metadata_get $token $category]
    }
}

proc qc::_aws_metadata_get { token category } {
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

proc qc::_aws_metadata_token { token_cache } {
    #| Return cached metadata token
    if { ![info exists $token_cache] } {
        qc::_aws_metadata_token_refresh $token_cache
    }
    return [set $token_cache]
}

proc qc::_aws_metadata_token_refresh { token_cache } {
    #| Refresh and cache metadata token
    qc::log Notice "qc::_aws_metadata_token_refresh on cache $token_cache"
    set token [qc::http_put \
                -data "" \
                -headers [list X-aws-ec2-metadata-token-ttl-seconds 21600] \
                http://169.254.169.254/latest/api/token \
              ]
    set $token_cache $token
    return $token
}

proc qc::aws_credentials_set { access_key secret_key {token ""}} {
    #| Set globals containing AWS credentials
    set ::env(AWS_ACCESS_KEY_ID) $access_key
    set ::env(AWS_SECRET_ACCESS_KEY) $secret_key
    if { $token ne "" } {
        set ::env(AWS_SESSION_TOKEN) $token
    }
    return true
}

proc qc::aws_region_set { region } {
    #| Set global containing AWS region
    set ::env(AWS_DEFAULT_REGION) $region
    return true
}

proc qc::aws_credentials_set_from_ec2_role { {region "eu-west-1"} } {
    #| Apply the EC2 role credentials found attached to this EC2 instance

    # Set region
    qc::aws_region_set $region

    # Set role credentials
    lassign [qc::aws_credentials_get_from_ec2_role] access_key secret_access_key token
    qc::aws_credentials_set $access_key $secret_access_key $token
}

proc qc::aws_credentials_get_from_ec2_role { } {
    #| Get role credentials from ec2 role metadata
    set role_name [qc::aws_metadata iam/security-credentials/]
    set role_credentials_json [qc::aws_metadata iam/security-credentials/${role_name}]
    set role_credentials_tson [qc::json2tson $role_credentials_json]
    set access_key [qc::tson_object_get_value $role_credentials_tson AccessKeyId]
    set secret_key [qc::tson_object_get_value $role_credentials_tson SecretAccessKey]
    set token [qc::tson_object_get_value $role_credentials_tson Token]
    return [list \
                $access_key \
                $secret_key \
                $token \
            ]
}
