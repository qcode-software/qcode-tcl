# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /var/lib/cvs/exf/tcl/db_cache.tcl,v 1.4 2003/02/18 11:57:59 nsadmin Exp $

doc db_cache {
    Title "Cached Database API"
    Description {
	The procs 
	<ul>
	<li>[doc_link db_cache_1row]
	<li>[doc_link db_cache_0or1row]
	<li>[doc_link db_cache_foreach] and
	<li>[doc_link db_cache_select_table]
	</ul>
	provide a database cache by storing results of executed queries in an nsv array with a hash of each qry used as the index.<br>
	Each time a cached proc is called, it checks to see if cached results exist and if so checks that the results are no older than the time-to-live given.If the cached results have not expired then it returns the cached results rather than going to fetch a fresh copy from the database.
	<p>
	The cached version of db procs can give speed improvements where the same query is executed repeatedly but at the expense of more memory usage. The operating system may already cache parts of the filesystem and the database may cache some query results.      
    }
    "See Also" {
	[doc_link db] and [doc_link db_thread_cache]
    }
}

proc qc::db_cache_1row { ttl qry } {
     # Cached equivalent of db_1row
    set table [db_cache_select_table $ttl $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>$qry</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

doc db_cache_1row {
    Parent db_cache
    Description {
	Cached equivalent of [doc_link db_1row]. Select one row from the cached results or the database if the cache has expired. Place variables corresponding to column names in the caller's namespace Throw an error if the number of rows returned is not exactly one.
	<p>
	Time-to-live is given in seconds.
    }
    Examples {
	# Cache the results of a query for 20 seconds
	% db_cache_1row 20 {select order_date from sales_order where order order_number=123}
	% set order_date
	2007-01-23
	% 
    }
}

proc qc::db_cache_0or1row { ttl qry {no_rows_code ""} {one_row_code ""} } {
    # Cached equivalent of db_0or1row
    set table [db_cache_select_table $ttl $qry 1]
    set db_nrows [expr {[llength $table]-1}]

    if {$db_nrows==0} {
	# no rows
	set code [ catch { uplevel 1 $no_rows_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode $result 
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
		return -code error -errorcode $errorCode $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } else {
	# more than 1 row
	error "The qry <code>$qry</code> returned $db_nrows rows"
    }
}

doc db_cache_0or1row {
    Parent db_cache
    Description {
	Cached equivalent of [doc_link db_0or1row].<br>
	Select zero or one row from the cached results or the database if the cache has expired. Place variables corresponding to column names in the caller's namespace.<br>
	If zero rows are returned then run no_rows_code else place variables corresponding to column names in the caller's namespace and execute one_row_body.
	<p>
	Time-to-live is given in seconds.
    }
    Examples {
	# Cache results for 20 seconds.
	% db_cache_0or1row 20 {select order_date from sales_orders where order order_number=123} {
	    puts "No Rows Found"
	} {
	    puts "Order Date $order_date"
	}
	No Rows Found
    }
}

proc qc::db_cache_foreach { ttl qry foreach_code { no_rows_code ""} } {
    # Cached equivalent of db_foreach
    global errorCode

     # save special db variables
    upcopy 1 db_nrows      saved_db_nrows
    upcopy 1 db_row_number saved_db_row_number

    set table [db_cache_select_table $ttl $qry 1] 
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
		return -code error -errorcode $errorCode $result 
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
		    return -code error -errorcode $errorCode $result 
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

doc db_cache_foreach {
    Parent db_cache
    Description {
	Cached equivalent of [doc_link db_foreach].<br> 
	Use cached results or the database if the cache has expired.
	Place variables corresponding to column names in the caller's namespace for each row returned.
	Set special variables db_nrows and db_row_number in caller's namespace to
	indicate the number of rows returned and the current row.<br>
	Time-to-live is given in seconds.
    }
    Examples {
	% set qry {select firstname,surname from users order by surname} 
	% db_cache_foreach 20 $qry {
	    lappend list "$surname, $firstname"
	}
    }
}

proc qc::db_cache_select_table {ttl qry {level 0}} {
    #| Check if the results of the qry have already been saved.
    #| If so check the age of the saved data using db_cache_timestamp
    #| If never saved or too old then run the qry and place the results
    #| as a table in the nsv db_cache 
    #| using the qry hash as index.
    incr level
    set hash [md5 [db_qry_parse $qry $level]]
    if { [ne [ns_cache names db $hash] ""] } { 
	return [ns_cache get db $hash]
    } else {
	set table [db_select_table $qry $level]
	ns_cache set db $hash $table
	return $table
    }
}

doc db_cache_select_table {
    Parent db_cache
     Examples {
	% db_cache_select_table 20 {select user_id,firstname,surname from users}
	% {user_id firstname surname} {73214205 Jimmy Tarbuck} {73214206 Des O'Conner} {73214208 Bob Monkhouse}

	% set surname MacDonald
	 % db_cache_select_table [expr 60*60*60*24] {select id,firstname,surname from users where surname=:surname}
	% {user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}
    }
}

proc qc::db_cache_clear { {qry ""} } {
    # clear the cache for the qry or all
    if { [eq $qry ""] } {
	foreach key [ns_cache names db] {
	    ns_cache flush db $key
	}
    } else {
	ns_cache flush db [md5 [db_qry_parse $qry 1]]
    }
}

doc db_cache_clear {
    Parent db_cache
    Description {
	Delete the results from the database cache for the query given. If no query is specified then remove all cached results.
    }
    Examples {
	# Delete the cache results for this query
	% db_cache_clear {select order_date from sales_order where order order_number=123}
	
	# Clear the entire cache
	% db_cache_clear
    }
}