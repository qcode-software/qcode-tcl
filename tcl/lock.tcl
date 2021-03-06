namespace eval qc {
    namespace export lock
}

proc qc::lock {lock_id timeout code} {
    #| Wait up to $timeout seconds to obtain a lock and then
    #| execute code 
    # TODO Aolserver only
    while { [nsv_incr lock $lock_id] != 1 } {
	if { $timeout>0 } {
	    ns_sleep 1
	    incr timeout -1
	} else {
	    error "Timout waiting for lock on $lock_id" {} TIMEOUT
	}
    }
    set return_code [ catch { uplevel 1 $code } result options ]
    nsv_unset lock $lock_id
    # Preserve TCL_RETURN
    if { $return_code == 2 && [dict get $options -code] == 0 } {
        dict set options -code return
    } else {
        dict incr options -level
    }
    return -options $options $result
}
