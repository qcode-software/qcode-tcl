package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::param { param_name } {
    global $param_name
    if { [info exists $param_name] } {
        # global variable
        return [set $param_name]
    } elseif { [info commands ns_config] eq "ns_config" && [ne [set param_value [ns_config ns/server/[ns_info server] $param_name]] ""] } {
        # Aolserver param
	return $param_value
    } elseif { [info commands ns_db] eq "ns_db" } {
        # DB param
        set qry {select param_value from param where param_name=:param_name}
        db_cache_1row -ttl 86400 $qry
        return $param_value
    } else {
        # I give up
        error "I don't know how to find param $param_name"
    }
}


proc qc::param_exists { param_name } {
    if { [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
	return true
    }
    set qry {select param_value from param where param_name=:param_name}
    db_cache_0or1row -ttl 86400 $qry {
	return false
    } {
	return true
    }
}
