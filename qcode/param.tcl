package provide qcode 1.8
package require doc
namespace eval qc {}

proc qc::param { param_name } {
    #| Return param value.
    #| First checks if param_name exists as a variable in param:: namespace (as used by muppet)
    #| then tries nsd params and DB.
    if { [info exists param::${param_name}] } {
        return [set param::${param_name}]
    } 
    if { [info commands ns_config] eq "ns_config" && [ne [set param_value [ns_config ns/server/[ns_info server] $param_name]] ""] } {
        # Aolserver param
	return $param_value
    } 
    if { [info commands ns_db] eq "ns_db" } {
        # DB param
        set qry {select param_value from param where param_name=:param_name}
        db_cache_0or1row -ttl 86400 $qry {
            # Not found in DB
        } {
            return $param_value
        }
    } 
    # I give up
    error "I don't know how to find param $param_name"
}


proc qc::param_exists { param_name } {
    #| Check for param existence.
    #| First checks if param_name exists as a variable in param:: namespace (as used by muppet)
    #| then tries nsd params and DB.
    if { [info exists param::${param_name}] && [set param::${param_name}] ne ""} {
	return true
    }
    if { [info commands ns_config] eq "ns_config" && [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
	return true
    }
    if { [info commands ns_db] eq "ns_db" } {
        set qry {select param_value from param where param_name=:param_name}
        db_cache_0or1row -ttl 86400 $qry {
	    return false
        } {
	    return true
        }
    }
    return false
}
