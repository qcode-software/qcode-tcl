proc qc::is_base64 {string} {
    #| Deprecated - see qc::is base64
    #| Checks input has only allowable base64 characters and is of the correct format
    return [qc::is base64 $string]
}
