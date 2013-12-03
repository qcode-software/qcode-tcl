package provide qcode 2.4.1
package require doc
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
    set code [ catch { uplevel 1 $code } result ]
    nsv_unset lock $lock_id 
    switch $code {
	1 { 
	    global errorCode errorInfo
	    return -code error -errorcode $errorCode $result 
	}
	default {
	    return -code $code $result
	}
    }
}
