proc qc::is_url {args} {
    #| Deprecated - see qc::is url
    #| This is a more restrictive subset of all legal uri's defined by RFC 3986
    #| Relax as needed
    return [qc::is url {*}$args]
}
