proc qc::is_postcode { postcode } {
    #| Deprecated - see qc::is postcode
    # uk postcode
    return [qc::is postcode $postcode]
}
