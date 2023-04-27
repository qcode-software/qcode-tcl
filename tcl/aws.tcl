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
    return [qc::http_get -noproxy http://169.254.169.254/latest/meta-data/$category]
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
