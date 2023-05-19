proc qc::is_non_zero_decimal { number } {
    #| Deprecated
    if { [string is double -strict $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}
