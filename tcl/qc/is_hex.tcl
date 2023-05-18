proc qc::is_hex {string} {
    #| Deprecated - see qc::is hex
    #| Does the input look like a hex number?
    return [qc::is hex $string]
}
