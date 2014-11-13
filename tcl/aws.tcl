namespace eval qc {
    namespace export aws_metadata
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
