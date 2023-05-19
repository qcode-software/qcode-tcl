proc qc::is_cidrnetv4 {string} {
    #| Deprecated - see qc::is cidrnetv4
    return [qc::is cidrnetv4 $string]
}
