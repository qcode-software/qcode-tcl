proc qc::is_ipv4 {string} {
    #| Deprecated - see qc::is ipv4
    # TODO checks structure only, will allow 9999.9999.9999.9999
    return [qc::is ipv4 $string]
}
