proc qc::is_non_zero {number} {
    #| Deprecated
    if { [is_decimal $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}
