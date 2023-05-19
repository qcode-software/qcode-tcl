proc qc::is_uri_valid {uri} {
    #| Deprecated - see qc::is uri
    #| Test if the given uri is valid according to
    #| rfc3986 (https://tools.ietf.org/html/rfc3986)
    return [qc::is uri $uri]
}
