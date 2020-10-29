namespace eval qc {
    namespace export db_cache_*
}

proc qc::db_cache_1row { args } {
    # Cached equivalent of db_1row
    args $args -ttl ? -- qry 
    if { [info exists ttl] } {
	set table [db_cache_select_table -ttl $ttl $qry 1]
    } else {
	set table [db_cache_select_table $qry 1]
    }
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

proc qc::db_cache_0or1row { args } {
    # Cached equivalent of db_0or1row
    args $args -ttl ? -- qry {no_rows_code ""} {one_row_code ""}
    if { [info exists ttl] } {
	set table [db_cache_select_table -ttl $ttl $qry 1]
    } else {
	set table [db_cache_select_table $qry 1]
    }
    set db_nrows [expr {[llength $table]-1}]

    if {$db_nrows==0} {
	# no rows
	set return_code [ catch { uplevel 1 $no_rows_code } result options ]
        # Preserve TCL_RETURN
	if { $return_code == 2 && [dict get $options -code] == 0 } {
            dict set options -code return
        } else {
            # Return in parent stack frame instead of here
            dict incr options -level
        }
        return -options $options $result
    } elseif { $db_nrows==1 } { 
	# 1 row
	foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
	set return_code [ catch { uplevel 1 $one_row_code } result options ]
        # Preserve TCL_RETURN
        if { $return_code == 2 && [dict get $options -code] == 0 } {
            dict set options -code return
        } else {
            # Return in parent stack frame instead of here
            dict incr options -level
        }
        return -options $options $result
    } else {
	# more than 1 row
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
}

proc qc::db_cache_foreach { args } {
    # Cached equivalent of db_foreach
    args $args -ttl ? -- qry foreach_code { no_rows_code ""}

    # save special db variables
    qc::upcopy 1 db_nrows      saved_db_nrows
    qc::upcopy 1 db_row_number saved_db_row_number

    if { [info exists ttl] } {
	set table [db_cache_select_table -ttl $ttl $qry 1]
    } else {
	set table [db_cache_select_table $qry 1]
    }
    set db_nrows [expr {[llength $table]-1}]
    set db_row_number 0

    if { $db_nrows == 0 } {
	upset 1 db_nrows 0
	upset 1 db_row_number 0
	set return_code [ catch { uplevel 1 $no_rows_code } result options ]
        switch $return_code {
            0 {
                # ok
            }
            default {
                # error, return

                # Preserve TCL_RETURN
                if { $return_code == 2 && [dict get $options -code] == 0 } {
                    dict set options -code return
                } else {
                    # Return in parent stack frame instead of here
                    dict incr options -level
                }
                return -options $options $result
            }
        }
    } else {
	set masterkey [lindex $table 0]
	foreach list [lrange $table 1 end] {
	    upset 1 db_nrows $db_nrows
	    upset 1 db_row_number [incr db_row_number]
	    foreach key $masterkey value $list {
		upset 1 $key $value
	    }
            set return_code [ catch { uplevel 1 $foreach_code } result options ]
            switch $return_code {
                0 {
                    # ok
                }
                3 -
                4 {
                    # break, continue
                    return -options $options $result
                }
                default {
                    # error, return

                    # Preserve TCL_RETURN
                    if { $return_code == 2 && [dict get $options -code] == 0 } {
                        dict set options -code return
                    } else {
                        # Return in parent stack frame instead of here
                        dict incr options -level
                    }
                    return -options $options $result
                }
            }

            # Clean up the result variable to prevent Tcl's Copy on Write
            # process from adversely affecting performance
            unset result
	}
    }
    # restore saved variables
    if { [info exists saved_db_nrows] } {
	upset 1 db_nrows      $saved_db_nrows
	upset 1 db_row_number $saved_db_row_number
    }
}

proc qc::db_cache_select_table { args } {
    #| Check if the results of the qry have already been saved.
    #| If never saved (or has expired due to ttl) then run the qry and place the results
    #| as a table in either db_thread_cache global array, or if ttl was specified,
    #| a time limited ns_cache cache.
    args $args -ttl ? -- qry {level 0}
    incr level
    set hash [qc::md5 [db_qry_parse $qry $level]]

    # Use global array or ns_cache with ttl?
    if { [info exists ttl] && [info procs ::ns_cache] ne "" } {
        # Use ns_cache
        # Create the cache if it doesn't exist yet
        if { ! [in [ns_cache_names] db] } {
            # DB cache size
            set param_name db_cache_size
            db_0or1row {select param_value from param where param_name=:param_name} {
                # DB param does not exist
                if { [set param_value [ns_config ns/server/[ns_info server] $param_name]] ne "" } {
                    # naviserver config param exists
                    set db_cache_size $param_value
                } else {
                    # use default of 10 MB
                    set db_cache_size [expr 1024*1024]
                }
            } {
                # DB param exists 
                set db_cache_size $param_value
            }

            # Initialise db cache
	    ns_cache create db -size $db_cache_size 
	}

        if { [ns_cache names db $hash] ne "" \
		 && [nsv_exists db $hash] \
		 && (([clock seconds]-[nsv_get db $hash])<=$ttl) 
	 } {
	    # age of cache value < ttl
	    return [ns_cache get db $hash]
        } else {
	    set table [db_select_table $qry $level]
	    ns_cache set db $hash $table
	    nsv_set db $hash [clock seconds]
	    return $table
        }
    } else {
        # No ttl specified - use global array.
        global db_thread_cache    
        if { [info exists db_thread_cache($hash)] } {
	    return $db_thread_cache($hash)
        } else {
	    set db_thread_cache($hash) [db_select_table $qry $level]
        }
    }
}

proc qc::db_cache_clear { {qry ""} } {
    #| Clear the cache for the qry or all
    set hash [qc::md5 [db_qry_parse $qry 1]]

    # ns_cache cache
    if { [info procs ::ns_cache] ne "" } {
        if { [in [ns_cache_names] db] } {
            foreach key [ns_cache names db] {
                if { $qry eq "" || $key eq $hash } {
                    ns_cache flush db $key
                }
            }
        }
    }

    # Thread cache
    global db_thread_cache
    if { [info exists db_thread_cache] } {
        if { $qry eq ""} {
            unset db_thread_cache
        } else {
            if { [info exists db_thread_cache($hash)] } {
                unset db_thread_cache($hash)
            }
        }
    }
}

proc qc::db_cache_ldict { qry } {
    #| Cached equivalent of db_select_ldict
    #| Select the results of qry into a ldict
    set table [db_cache_select_table $qry 1]
    return [qc::table2ldict $table]
}

