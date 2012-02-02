package provide qcode 1.4
package require doc
namespace eval qc {}

proc qc::param { param_name } {
    if { [ne [set param_value [ns_config ns/server/[ns_info server] $param_name]] ""] } {
	return $param_value
    }
    set qry {select param_value from param where param_name=:param_name}
    db_cache_1row 86400 $qry
    return $param_value
}


proc qc::param_exists { param_name } {
    if { [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
	return true
    }
    set qry {select param_value from param where param_name=:param_name}
    db_cache_0or1row 86400 $qry {
	return false
    } {
	return true
    }
}
