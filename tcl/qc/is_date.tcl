proc qc::is_date { date } {
    #| Deprecated - see qc::is date
    # dates are expected to be in iso format 
    return [qc::is date $date] 
}

proc qc::is_date_castable {string} {
    #| Deprecated - see qc::castable date
    #| Can string be cast into date format?
    return [qc::castable date $string]
}
