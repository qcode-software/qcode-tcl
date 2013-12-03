package provide qcode 2.4.0
package require doc
namespace eval qc {
    namespace export param_exists param_set param_get
}
namespace eval qc::param {}

proc qc::param_get { param_name args } {
    #| Return param value.
    
    if { [llength $args] > 0 } {
        return [dict get [qc::param_get $param_name] {*}$args]
    } else {
        if { [info commands ns_db] eq "ns_db" } {
	    # Naviserver
            # DB param
            set qry {select param_value from param where param_name=:param_name}
            db_cache_0or1row -ttl 86400 $qry {
                # Not found in DB
            } {
                return $param_value
            } 

	    # Check for naviserver params
	    if { [info commands ns_config] eq "ns_config" && [ne [set param_value [ns_config ns/server/[ns_info server] $param_name]] ""] } {
		# Naviserver param
		return $param_value
	    } 
        } else {
	    # Non-Naviserver env
	    qc::param_datastore_load
	    # Check the datastore
	    if { [info exists ::qc::param::db] && [qc::in [array names ::qc::param::db] $param_name] } {
		return $::qc::param::db($param_name)
	    }
	}
        # I give up
        error "I don't know how to find param $param_name"
    }
}

proc qc::param_exists { param_name args } {
    #| Check for param existence.
    if { [llength $args] > 0 } {
        if { [qc::param_exists $param_name] } {
            return [dict exists [qc::param_get $param_name] {*}$args]
        } else {
            return false
        }
    } else {

        if { [info commands ns_db] eq "ns_db" } {
	    # Naviserver env
            # DB param
            set qry {select param_value from param where param_name=:param_name}
            db_cache_0or1row -ttl 86400 $qry {
                # Not found in DB
            } {
                return true
            }
	    
	    if { [info commands ns_config] eq "ns_config" && [ne [ns_config ns/server/[ns_info server] $param_name] ""] } {
		# Naviserver param
		return true
	    }
        } else {
	    # Non-naviserver
	    qc::param_datastore_load
	    if { [info exists ::qc::param::db] && [qc::in [array names ::qc::param::db] $param_name] } {
		return true
	    }
	}
        return false
    }
}

proc qc::param_set { param_name args } {
    #| Attempt to set param_name to param_value
    if { [llength $args] == 0 } {
        error "Usage: qc::param_set name ?key ...? value" 
    } elseif { [llength $args] > 1 } {
        if { [qc::param_exists $param_name] } {
            set param_value [qc::param_get $param_name]
            dict set param_value {*}$args
        } else {
            dict set param_value {*}$args 
        }
        return [qc::param_set $param_name $param_value]
    }
    # 2 args
    set param_value [lindex $args 0]
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
	array set ::qc::param::db [list $param_name $param_value]
	qc::param_datastore_save
    }

    return $param_value
}

proc qc::param_datastore_load {} {
    #| Load the datastore if it exists and isn't already in memory and is readable
    if { ![info exists ::env(HOME)] } {
	error "Don't know where your home directory is"
    }
    if { ![info exists ::qc::param::db] && [file exists $::env(HOME)/.muppet/db] } {
        set fh [open $::env(HOME)/.muppet/db r]
        array set ::qc::param::db [read -nonewline $fh]
        close $fh
    }
}

proc qc::param_datastore_save {} {
    #| Write out the params to disk.
    if { ![info exists ::env(HOME)] } {
	error "Don't know where your home directory is"
    }
    set filename "$::env(HOME)/.muppet/db"
    if { ![file exists $filename] } {
	file mkdir [file dirname $filename]
    }
    # Write to datastore
    set fh [open $filename w]
    puts -nonewline $fh [array get ::qc::param::db]
    close $fh
    file attributes $filename -permissions 0600
}

