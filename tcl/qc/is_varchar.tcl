proc qc::is_varchar {string length} {
    #| Deprecated - see qc::is varchar
    #| Checks string would fit in a varchar of length $length
    return [qc::is varchar $length $string]
}
