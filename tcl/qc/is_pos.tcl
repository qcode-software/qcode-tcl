proc qc::is_pos {number} {
    #| Deprecated
    if { [is_decimal $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}
