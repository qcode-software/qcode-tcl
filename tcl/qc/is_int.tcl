proc qc::is_int_castable {string} {
    #| Deprecated - see qc::castable integer
    #| Can input be cast to an integer?
    return [qc::castable integer $string]
}
