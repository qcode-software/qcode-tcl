proc qc::is_pnz_decimal { price } {
    #| Deprecated
    # positive non-zero double
    if { [string is double -strict $price] && $price>0 } {
	return 1
    } else {
	return 0
    }
}
