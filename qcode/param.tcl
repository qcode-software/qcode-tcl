package provide qcode 2.0
package require doc
namespace eval qc {}

proc qc::param_get { param_name } {
    #| Return param value.

    # Check the DB
    if { [info commands ns_db] eq "ns_db" } {
        # DB param
        set qry {select param_value from param where param_name=:param_name}
        db_cache_0or1row -ttl 86400 $qry {
            # Not found in DB
        } {
            return $param_value
        }
    } 

    # Check for a muppet datastore
    #
    # Load the datastore if it exists
    if { ![info exists ::qc::param::db] && [file exists /var/db/muppet] } {
        # Read the datastore
        set fh [open /var/db/muppet r]
        array set ::qc::param::db [read -nonewline $fh]
        close $fh
    }
    # Check the datastore
    if { [info exists ::qc::param::db] && [qc::in [array names ::qc::param::db] $param_name] } {
        return $::qc::param::db($param_name)
    }
    
    # Check for naviserver params
    if { [info commands ns_config] eq "ns_config" && [ne [set param_value [ns_config ns/server/[ns_info server] $param_name]] ""] } {
        # Aolserver param
	return $param_value
    }
    # I give up
    error "I don't know how to find param $param_name"
}


proc qc::param_exists { param_name } {
    #| Check for param existence.
    if { [info commands ns_db] eq "ns_db" } {
        # DB param
        set qry {select param_value from param where param_name=:param_name}
        db_cache_0or1row -ttl 86400 $qry {
            # Not found in DB
        } {
	    return true
        }
    }
    if { ![info exists ::qc::param::db] && [file exists /var/db/muppet]} {
        # read param db from disk
        set fh [open /var/db/muppet r]
        array set ::qc::param::db [read -nonewline $fh]
        close $fh
    } 
    if { [info exists ::qc::param::db] && [qc::in [array names $::qc::param::db] $param_name] } {
        return true
    }
    if { [info commands ns_config] eq "ns_config" && [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
        # Naviserver param
	return true
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

    if { [info commands ns_db] eq "ns_db" } {
        # Check the DB table
        db_0or1row { select param_value as existing_value from param where param_name=:param_name } {
            # new db param
            db_dml {insert into param values(:param_name,:param_value)}
        } {
            # updating an existing db param
            db_cache_clear [db_qry_parse "select param_value from param where param_name=:param_name"]
            db_dml { update param set param_value=:param_value where param_name=:param_name }
        }
    } else {
        # Load the datastore if it exists and isn't already in memory
        if { ![info exists ::qc::param::db] && [file exists /var/db/muppet] } {
            # Read the datastore
            set fh [open /var/db/muppet r]
            array set ::qc::param::db [read -nonewline $fh]
            close $fh
        }
        # Set the datastore
        array set ::qc::param::db [list $param_name $param_value]
        # Write to disk
        set fh [open /var/db/muppet w]
        puts -nonewline $fh [array get $::qc::param::db]
        close $fh
    }
    return $param_value
}
