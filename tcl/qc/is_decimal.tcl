proc qc::is_decimal { number } {
    #| Deprecated - see qc::is decimal
    return [qc::is decimal $number]
}

proc qc::is_decimal_castable {string} {
    #| Deprecated - see qc::castable decimal
    return [qc::castable decimal $string]
}
