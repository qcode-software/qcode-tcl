proc qc::is_non_zero_integer {int} {
    #| Deprecated
    if { [is_integer $int] && $int!=0 } {
	return 1
    } else {
	return 0
    }
}
