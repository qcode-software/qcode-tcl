# Copyright (C) 2001-2006, Bernhard van Woerden <bernhard@qcode.co.uk>
# All rights reserved.
#
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
# $Header: /var/lib/cvs/exf/tcl/db_thread_cache.tcl,v 1.4 2003/03/01 18:14:49 nsadmin Exp $

#| This provides a database caching mechanism on a 
#| per thread basis using thread global variables.

doc db_thread_cache {
    Title "Thread Cached Database API"
    Description {
	This cache mechanism differs from the [doc_link db_cache] in that this cache expires when the thread exists whereas the other cache mechanism has an explicit time-to-live.
	<p>
	The procs 
	<ul>
	<li>[doc_link db_thread_cache_1row]
	<li>[doc_link db_thread_cache_0or1row]
	<li>[doc_link db_thread_cache_foreach] and
	<li>[doc_link db_thread_cache_select_table]
	</ul>
	provide a database cache by storing results of executed queries in a global array with a hash of each qry used as the index.<br>
	Each time a cached proc is called, it checks to see if cached results exist and if so it returns the cached results rather than going to fetch a fresh copy from the database.
	<p>
	The cached version of db procs can give speed improvements where the same query is executed repeatedly but at the expense of more memory usage. The operating system may already cache parts of the filesystem and the database may cache some query results.    
    }
    "See Also" {
	[doc_link db] and [doc_link db_cache]
    }
}

proc qc::db_thread_cache_1row { qry } {
     # Thread Cached equivalent of db_1row
    set table [db_thread_cache_select_table $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

doc db_thread_cache_1row {
    Parent db_thread_cache
    Description {
	Thread-Cached equivalent of [doc_link db_1row]. Select one row from the cached results or the database if the cache is empty. Place variables corresponding to column names in the caller's namespace Throw an error if the number of rows returned is not exactly one.
	<p>
	Cached results are expired when the thread terminates. AOLserver cleans up globals for the thread at exit.
    }
    Examples {
	# Thread-Cache the results of a query
	% db_thread_cache_1row {select order_date from sales_order where order order_number=123}
	% set order_date
	2007-01-23
	% 
    }
    "See Also" {
	[doc_link db.html] and [doc_link db_cache.html]
    }
}

proc qc::db_thread_cache_0or1row { qry {no_rows_code ""} {one_row_code ""} } {
    # Thread Cached equivalent of db_0or1row
    set table [db_thread_cache_select_table $qry 1]
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

doc db_thread_cache_0or1row {
    Parent db_thread_cache
    Description {
	Thread-Cached equivalent of [doc_link db_0or1row].<br>
	Select zero or one row from the cached results or the database if the cache is empty. Place variables corresponding to column names in the caller's namespace.<br>
	If zero rows are returned then run no_rows_code else place variables corresponding to column names in the caller's namespace and execute one_row_body.
	<p>
	Cached results expire when the thread terminates. AOLserver cleans up TCL globals for the thread at exit.
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

proc qc::db_thread_cache_foreach { qry foreach_code { no_rows_code ""} } {
    # Thread Cached equivalent of db_foreach
    global errorCode

     # save special db variables
    upcopy 1 db_nrows      saved_db_nrows
    upcopy 1 db_row_number saved_db_row_number

    set table [db_thread_cache_select_table $qry 1] 
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

doc db_thread_cache_foreach {
    Parent db_thread_cache
    Description {
	Thread-Cached equivalent of [doc_link db_foreach].<br> 
	Use cached results or the database if the cache is empty.
	Place variables corresponding to column names in the caller's namespace for each row returned.
	Set special variables db_nrows and db_row_number in caller's namespace to
	indicate the number of rows returned and the current row number.
	<p>
	Cached results expire when the thread terminates. AOLserver cleans up TCL globals for the thread at exit.
    }
    Examples {
	% set qry {select firstname,surname from users order by surname} 
	% db_thread_cache_foreach $qry {
	    lappend list "$surname, $firstname"
	}
    }
}

proc qc::db_thread_cache_ldict { qry } {
    # Thread Cached equivalent of db_select_ldict
    set table [db_thread_cache_select_table $qry 1]
    return [qc::table2ldict $table]
}


proc qc::db_thread_cache_select_table {qry {level 0} } {
    # Check if the results of the qry have already been cached.
    # If not run the qry and place the results
    # as a table in the global array db_thread_cache 
    # using a hash of the the qry as an index.

    global db_thread_cache    
    incr level
    set hash [ns_sha1 [db_qry_parse $qry $level]]
    if { [info exists db_thread_cache($hash)] } {
	return $db_thread_cache($hash)
    } else {
	set db_thread_cache($hash) [db_select_table $qry $level]
    }
}

doc db_thread_cache_select_table {
    Parent db_thread_cache
    Description {
	Check if the results of the qry have already been cached. If not run the qry and place the results as a table in the global array db_thread_cache using a hash of the the qry as an index.
	<p>
	Cached results expire when the thread terminates. AOLserver cleans up TCL globals for the thread at exit.
    }
    Examples {
	% db_thread_cache_select_table {select user_id,firstname,surname from users}
	% {user_id firstname surname} {73214205 Jimmy Tarbuck} {73214206 Des O'Conner} {73214208 Bob Monkhouse}

	% set surname MacDonald
	% db_thread_cache_select_table {select id,firstname,surname from users where surname=:surname}
	% {user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}
    }
}
