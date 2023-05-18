proc qc::is_mobile_number {string} {
    #| Deprecated - see qc::is mobile_number
    # uk mobile telephone number
    return [qc::is mobile_number $string]
}
