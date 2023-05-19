proc qc::is_timestamp_http { date } {
    #| Deprecated - see qc::is timestamp_http
    #| Returns true if date is an acceptable HTTP timestamp.
    #| Note although all three should be accepted, only RFC 1123 format should be
    #| generated.
    # RFC 1123 - Sun, 06 Nov 1994 08:49:37 GMT
    return [qc::is timestamp_http $date]
}

proc qc::is_timestamp { date } {
    #| Deprecated - see qc::is timestamp
    # timestamps are expected to be in iso format 
    return [qc::is timestamp $date]
}

proc qc::is_timestamp_castable {string} {
    #| Deprecated - see qc::castable timestamp
    #| Can string be cast into timestamp format?
    return [qc::castable timestamp $string]
}
