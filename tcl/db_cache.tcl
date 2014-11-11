
package require doc
namespace eval qc {
    namespace export db_cache_*
}

doc db_cache {
    Title "Cached Database API"
    Description {
	The procs 
	<ul>
	<li><proc>db_cache_1row</proc>
	<li><proc>db_cache_0or1row</proc>
	<li><proc>db_cache_foreach</proc> and
	<li><proc>db_cache_select_table</proc>
	</ul>
	provide a database cache by storing results of executed queries in either a time limited ns_cache cache (if a ttl is specified), or a global array which will persist for the life of the thread (if no ttl is specified). A hash of each qry used as the index.<br>
	Each time a cached proc is called, it checks to see if cached results exist. If the cached results exist then it returns the cached results rather than going to fetch a fresh copy from the database.
	<p>
	The cached version of db procs can give speed improvements where the same query is executed repeatedly but at the expense of more memory usage. The operating system may already cache parts of the filesystem and the database may cache some query results.      
    }
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
	set code [ catch { uplevel 1 $no_rows_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } elseif { $db_nrows==1 } { 
	# 1 row
	foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
	set code [ catch { uplevel 1 $one_row_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } else {
	# more than 1 row
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
}



proc qc::db_cache_foreach { args } {
    # Cached equivalent of db_foreach
    args $args -ttl ? -- qry foreach_code { no_rows_code ""}
    global errorCode errorInfo

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
	set returnCode [ catch { uplevel 1 $no_rows_code } result ]
	switch $returnCode {
	    0 {
		# normal
	    }
	    1 { 
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $returnCode $result
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
	    set returnCode [ catch { uplevel 1 $foreach_code } result ]
	    switch $returnCode {
		0 {
		    # Normal
		}
		1 { 
		    return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
		}
		2 {
		    return -code return $result
		}
		3 {
		    break
		}
		4 {
		    continue
		}
	    }
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
    if { [info exists ttl] } {
        # Use ns_cache
        # Create the cache if it doesn't exist yet
        if { ! [in [ns_cache_names] db] } {
	    ns_cache create db -size [expr 1024*1024] 
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
    if { [in [ns_cache_names] db] } {
	foreach key [ns_cache names db] {
	    if { $qry eq "" || $key eq $hash } {
		ns_cache flush db $key
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


