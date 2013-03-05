package provide qcode 1.17
package require doc
namespace eval qc {}

proc qc::param { param_name } {
    #| Return param value.
    #| First checks if param_name exists as a variable in param:: namespace (as used by muppet)
    #| then tries nsd params and DB.
    if { [info exists param::${param_name}] && [set param::${param_name}] ne ""} {
        # Var in param:: namespace
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
        # Var in param:: namespace
	return true
    }
    if { [info commands ns_config] eq "ns_config" && [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
        # Aolserver param
	return true
    }
    if { [info commands ns_db] eq "ns_db" } {
        # DB param
        set qry {select param_value from param where param_name=:param_name}
        db_cache_0or1row -ttl 86400 $qry {
            # Not found in DB
        } {
	    return true
        }
    }
    return false
}

proc qc::param_set { param_name param_value } {
    #| Attempt to set param_name to param_value

    # First check this doesn't exist in ns_config in which case it is read-only and we cannot set it here.
    if { [info commands ns_config] eq "ns_config" && [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
        # We cannot set this param programmatically
        error "Param $param_name is read-only" {} USER
    }

    # For completeness - check if this is in param:: namespace as used by muppet and set it there if so
    if { [info exists param::${param_name}] && [set param::${param_name}] ne ""} {
        # Var in param:: namespace
        return [set param::${param_name} $param_value]
    }

    # Check the DB table
    db_0or1row { select param_value as existing_value from param where param_name=:param_name } {
        # new db param
        db_dml {insert into param values(:param_name,:param_value)}
    } {
        # updating an existing db param
        db_cache_clear [db_qry_parse "select param_value from param where param_name=:param_name"]
        db_dml { update param set param_value=:param_value where param_name=:param_name }
    }
    return $param_value
}
