proc qc::is_creditcard { no } {
    #| Deprecated - see qc::is creditcard
    #| Checks if no is an allowable credit card number
    #| Checks, number of digits are >13 & <19, all characters are integers, luhn 10 check
    return [qc::is creditcard $no]
}

proc qc::is_creditcard_masked { no } {
    #| Deprecated - see qc::is creditcard_masked
    #| Check the credit card number is masked to PCI requirements
    return [qc::is creditcard_masked $no]
}
