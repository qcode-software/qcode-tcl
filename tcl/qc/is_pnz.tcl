proc qc::is_pnz {number} {
    #| Deprecated
    if { [is_decimal $number] && $number>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_int { int } {
    #| Deprecated
    # positive non zero integer
    if { [is_integer $int] && $int > 0 } {
	return 1
    } else {
	return 0
    }
}
