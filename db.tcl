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
# $Header: /home/bernhard/cvs/exf/tcl/qc::db.tcl,v 1.9 2003/07/31 23:04:34 bernhard Exp $


proc qc::db_qry_parse {qry {level 0} } {
    #| parses a SQL query replacing bind variables
    #| (ACS) like :varname with a quoted version
    #| of $varname in the caller level $level's env
    incr level

    # Quoted fields: Escape colons with \0 and []$\\
    # regsub -all won't work because the regexp need to be applied repeatedly to anchor correctly
    set start 0
    while { $start<[string length $qry] && [regexp -indices -start $start -- {(^|[^'])'(([^']|'')*)'([^']|$)} $qry -> left field . right] } {
	set qry [string replace $qry [lindex $field 0] [lindex $field 1] [string map {: \0 [ \1 ] \2 $ \3 \\ \4} [string range $qry [lindex $field 0] [lindex $field 1]]]]
	set start [lindex $right 0]
    }
    # SQL Arrays
    # array[2:3]
    regsub -all {\[([0-9]+:[0-9]+)\]} $qry {\\[\1\\]} qry
    # array[2]
    regsub -all {\[([0-9]+)\]} $qry {\\[\1\\]} qry
    # array[:index] or array[$index]
    regsub -all {\[((:|\$)[a-zA-Z_][a-zA-Z0-9_]*)\]} $qry {\\[\1\\]} qry
    # TODO: Dollar quoted string like $foo$ or $tag$foo$tag$

    # Colon variable substitution
    regsub -all {([^:]):([a-zA-Z_][a-zA-Z0-9_]*)} $qry {\1[db_quote [set \2]]} qry

    # Eval with uplevel
    set qry [uplevel $level [list subst $qry]]

    # =NULL to IS NULL
    if {[regexp -nocase {^[ \t\r\n]*select[ \t\r\n]} $qry]} {
	# A select query
	regsub -all {=NULL} $qry { IS NULL} qry
    }
    return [string map {\0 : \1 [ \2 ] \3 $ \4 \\} $qry]
}

proc qc::db_quote { value } {
    #| quotes SQL values by escaping single quotes with \'
    #| leaves integers and doubles alone
    #| Empty strings are converted to NULL
    if { [string equal $value ""] } {
	return "NULL"
    }
    # integer no leading zeros
    # -123456
    if { [regexp {^-?[1-9][0-9]*$} $value] || [string equal $value 0] } {
	return $value
    }
    # double greater than 1
    if { [regexp {^-?[1-9][0-9]*\.[0-9]+$} $value] } {
	return $value
    }
    # decimal less than 1
    # in form .23 or 0.23
    if { [regexp {^(-)?0?\.([0-9]+)$} $value -> sign tail] } {
	return "${sign}0.${tail}"
    }
    # scientific notation
    if { [regexp {^-?[1-9][0-9]*(\.[0-9]+)?(e|E)(\+|-)?[0-9]{1,2}$} $value] } {
	return $value
    }
    # replace ' with '' and \ with \\ 
    # (tcl also uses slash to escape hence \\ in string map)
    if { [string first \\ $value]==-1 } {
	return "'[string map {' ''} $value]'"
    } else {
	return "E'[string map {' '' \\ \\\\} $value]'"
    }
}

doc db_quote {
    Parent db
    Description {
	Escape strings that contain single quotes e.g. O'Neil becomes 'O''Neil' Empty strings are replaced with NULL. Numbers are left unchanged. 
    }
    Examples {
	% db_quote 23
	% 23

	% db_quote 0800
	% '0800'

	% db_quote MacKay
	% 'MacKay'

	% db_quote O'Neil
	% 'O''Neil'

	% db_quote ""
	% NULL
    }
}

proc qc::db_escape_regexp { string } {
    # The postgresql parser performs substitution 
    # before passing the regexp to the regexp engine
    # So to find a match for a regex metacharacter
    # we need to escape the preceding slash.
    # For example "foo." becomes "foo\\."
    regsub -all {\\} $string {\\\\} string

    regsub -all {\^} $string {\\^} string
    regsub -all {\.} $string {\\.} string

    regsub -all {\[} $string {\\[} string
    regsub -all {\]} $string {\\]} string

    regsub -all {\$} $string {\\$} string

    regsub -all {\(} $string {\\(} string
    regsub -all {\)} $string {\\)} string

    regsub -all {\|} $string {\\|} string
    regsub -all {\*} $string {\\*} string
    regsub -all {\+} $string {\\+} string
    regsub -all {\?} $string {\\?} string
    regsub -all {\{} $string {\\\{} string
    regsub -all {\}} $string {\\\}} string

    return $string
}

doc db_escape_regexp {
    Parent db
    Usage {db_escape_regexp string}
    Description {
	Used to escape regular expression metacharacters. 
    }
    Examples {
	% db_escape_regexp Finlay.son
	% Finlay\.son

	% db_escape_regexp "*fish"
	% \*fish

	% db_escape_regexp {C:\one\tow}
	% C:\\one\\tow

	% set email andrew.
	% set qry "select * from customer where email ~* [db_quote "^[db_escape_regexp $email]"]"
	select * from customer where email ~* '^andrew\.'
    }
}

proc qc::db_get_handle {{poolname DEFAULT}} {
    # Return db handle 
    # Keep one handle per pool for current thread.
    global _db
    if { ![info exists _db($poolname)] } {
	if { [string equal $poolname DEFAULT] } {
	    set _db($poolname) [ns_db gethandle]
	} else {
	    set _db($poolname) [ns_db gethandle $poolname]
	}
    }
    return $_db($poolname)
}

doc db_get_handle {
    Parent db
    Description {
	Return a database handle.
	Keep one handle per pool for current thread in a thread global variable.
	At thread exit AOLserver will release the db handle.
    }
}

proc qc::db_dml { args } {
    args $args -db DEFAULT -- qry
    #| Execute a SQL dml statement
    set db [db_get_handle $db]
    set qry [db_qry_parse $qry 1]
    try {
	ns_db dml $db $qry
    } {
	global errorInfo
	error "Failed to execute dml <code>$qry</code>.<br>[ns_db exception $db]" $errorInfo
    }
}

doc db_dml {
    Parent db
    Usage {db_dml qry}
    Description {Execute a SQL dml statement}
    Examples {
	% db_dml {update users set email='foo@bar.com' where user_id=23}

	% db_dml {insert into users (user_id,name,email) values (1,'john','john@example.com') }
    }
}

proc qc::db_trans {args} {
    #| Execute code within a transaction
    #| Rollback on database or tcl error
    #| Nested db_trans structures do not
    #| emulate postgres nested transactions but simply
    #| ensure code is executed in a transaction by
    #| maintaining a global db_trans_level
    args $args -db DEFAULT -- code {error_code ""}
    global db_trans_level errorInfo errorCode
    if { ![info exists db_trans_level] } {
	set db_trans_level($db) 0
    }
    
    if { $db_trans_level($db) == 0 } {
	db_dml -db $db "BEGIN WORK"
	incr db_trans_level($db)
    } else {
	incr db_trans_level($db)
    }
    set code [ catch { uplevel 1 $code } result ]
    switch $code {
	1 {
	    # Error
	    if { $db_trans_level($db) >= 1 } {
		db_dml "ROLLBACK WORK"
		set db_trans_level($db) 0
	    }
	    uplevel 1 $error_code
	    return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	}
	default {
	    # normal,return,break,continue
	    if { $db_trans_level($db) == 1 } {
		db_dml "COMMIT WORK"
		set db_trans_level($db) 0
	    } else {
		incr db_trans_level($db) -1
	    }
	    return -code $code $result
	}
    }
}

doc db_trans {
    Parent db
    Usage {db_trans code ?on_error_code?}
    Description {
	Execute code within a database transaction.
	Rollback on database or tcl error.
    }
    Examples {
	db_trans {
	    db_dml {update account set balance=balance-10 where account_id=1}
	    db_dml {update account set balance=balance+10 where account_id=2}
	}

	db_trans {
	    # Select for update
	    db_dml {select order_state from sales_order where order_number=123 for update}
	    if { ![string equal $order_state OPEN ] } {
		# Throw error and ROLLBACK
		error "Can't invoice sales order $order_number because it is not OPEN"
	    }
	    # Perform action that requires order to be OPEN
	    invoice_sales_order 123
	}

	db_trans {
	    blow-up
	} {
	    # cleanup here
	}
    }
}

proc qc::db_1row { args } {
    # Select 1 row from the database using the qry.
    # Place variables corresponding to column names in the caller's namespace
    # Throw an error if more or less than 1 row is returned.
    args $args -db DEFAULT -- qry
    set table [db_select_table -db $db $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

doc db_1row {
    Parent db
    Usage {db_1row qry}
    Description {
	Select one row from the database using the qry. Place variables corresponding to column names in the caller's namespace Throw an error if more or less than 1 row is returned.
    }
    Examples {
	% db_1row {select order_date from sales_order where order order_number=123}
	% set order_date
	2007-01-23
	%
	% set order_number 567545
	% db_1row {select order_date from sales_order where order order_number=:order_number}
	% set order_date
	2006-02-05
    }
}

proc qc::db_0or1row {args} {
    # Select zero or one row from the database using the qry.
    # If zero rows are returned then run no_rows_code else 
    # place variables corresponding to column names in the caller's namespace and execute one_row_body
    args $args -db DEFAULT -- qry {no_rows_code ""} {one_row_code ""}
    set table [db_select_table -db $db $qry 1]
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

doc db_0or1row {
    Parent db
    Usage {db_0or1row qry ?no_rows_code? ?one_row_code?}
    Description {
	Select zero or one row from the database using the qry.
	If zero rows are returned then run no_rows_code else 
	place variables corresponding to column names in the caller's namespace and execute one_row_body
    }
    Examples {
	% db_0or1row {select order_date from sales_orders where order order_number=123} {
	    puts "No Rows Found"
	} {
	    puts "Order Date $order_date"
	}
	No Rows Found
	%
	set order_number 654456
	db_0or1row {select order_date from sales_orders where order order_number=:order_number} {
	    puts "No Rows Found"
	} {
	    puts "Order Date $order_date"
	}
	Order Date 2007-06-04
    }
}

proc qc::db_foreach {args} {
    #| Place variables corresponding to column names in the caller's namespace
    #| for each row returned.
    #| Set special variables db_nrows and db_row_number in caller's namespace to
    #| indicate the number of rows returned and the current row.
    #| Nested foreach statements clean up special variables so they apply to the current scope.
    args $args -db DEFAULT -- qry foreach_code { no_rows_code ""}
    global errorCode

     # save special db variables
    upcopy 1 db_nrows      saved_db_nrows
    upcopy 1 db_row_number saved_db_row_number

    set table [db_select_table -db $db $qry 1] 
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

doc db_foreach {
    Parent db
    Description {
	Place variables corresponding to column names in the caller's namespace for each row returned.
	Set special variables db_nrows and db_row_number in caller's namespace to
	indicate the number of rows returned and the current row.
	Nested foreach statements clean up special variables so they apply to the current scope.
    }
    Examples {
	% set qry {select firstname,surname from users order by surname} 
	% db_foreach $qry {
	    lappend list "$surname, $firstname"
	}

	% set category Lights
	% set qry {
	    select product_code,description,price 
	    from products 
	    where category=:category 
	    order by product_code
	}
	% db_foreach $qry {
	    append html &lt;li&gt;$db_row_number $product_code $description $price&lt;/li&gt;
	}
    }
}

proc qc::db_seq {args} {
    args $args -db DEFAULT -- seq_name
    # Fetch the next value from the sequence named seq_name
    set qry "select nextval(:seq_name) as next_id"
    db_1row -db $db $qry
    return $next_id
}

doc db_seq {
    Parent db
    Description {Fetch the next value from the sequence named seq_name}
    Examples {
	% db_dml {create sequence sales_order_no_seq}
	% set sales_order_no [db_seq sales_order_no_seq]
	% 1
    }
}

proc qc::db_select_table {args} {
    # Select results of qry into a table
    # Parse qry at level given
    args $args -db DEFAULT -- qry {level 0}
    incr level
    set qry [db_qry_parse $qry $level]
    set table {}
    set db [db_get_handle $db]
    try {
	set row [ns_db select $db $qry]
	lappend table [ns_set_keys $row]
	while { [ns_db getrow $db $row] } {
	    lappend table [ns_set_values $row]
	}
	return $table
    } {
	error "Failed to execute qry <code>$qry</code><br>[ns_db exception $db]"
    }
}

doc db_select_table {
    Parent db
    Description {Select the results of the query into a [doc_link table]. Substitute and quote bind variables starting with a colon.}
    Examples {
	% db_select_table {select user_id,firstname,surname from users}
	% {user_id firstname surname} {73214205 Jimmy Tarbuck} {73214206 Des O'Conner} {73214208 Bob Monkhouse}

	% set surname MacDonald
	% db_select_table {select id,firstname,surname from users where surname=:surname}
	% {user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}
    }
}

proc qc::db_select_csv { qry {level 0} } {
    #| Select qry into csv report
    #| First row contains column names
    incr level
    set qry [db_qry_parse $qry $level]
    set lines {}
    set db [db_get_handle]
    try {
	set row [ns_db select $db $qry]
	lappend lines [list2csv [ns_set_keys $row]]
	while { [ns_db getrow $db $row] } {
	    lappend lines [list2csv [ns_set_values $row]]
	}
	return [join $lines \r\n]
    } {
	error "Failed to execute qry <code>$qry</code><br>[ns_db exception $db]"
    }
}

doc db_select_csv {
    Parent db
    Description {Select the results of the SQL qry into a csv report. First row contains column names.Lines separated with windows \\r\\n}
    Examples {
	% db_select_csv {select user_id,firstname,surname from users}
	user_id,firstname,surname
	83214205,Angus,MacDonald
	83214206,Iain,MacDonald
	83214208,Donald,MacDonald
    }
}

proc qc::db_select_ldict { qry } {
    # Select the results of qry into a ldict
    set table [db_select_table $qry 1]
    return [qc::table2ldict $table]
}

doc db_select_ldict {
    Parent db
    Description {Select the results of the SQL qry into a ldict. An ldict is a list of dicts}
    Examples {
	% set qry {select firstname,surname from users}
	% db_select_ldict $qry
	{firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus surname McNeil}
    }
}

proc qc::db_select_dict { qry } {
    # Select 0 or 1 row from the database using the qry.
    # Place result in a dict
    # Throw an error if more than 1 row is returned.

    set table [db_select_table $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows>1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    set dict {}
    foreach key [lindex $table 0] value [lindex $table 1] { lappend dict $key $value }
    return $dict
}

proc qc::db_col_varchar_length { table_name col_name } {
    #| Returns the varchar length of a db table column
    set qry "
        SELECT
                a.atttypmod-4 AS lengthvar,
                t.typname AS type
        FROM
                pg_attribute a,
                pg_class c,
                pg_type t
        WHERE
                c.relname = :table_name
                and a.attnum > 0
                and a.attrelid = c.oid
                and a.atttypid = t.oid
                and a.attname = :col_name
        ORDER BY a.attnum
    "
    db_0or1row $qry {
    error "No such column \"$col_name\" in table \"$table_name\""
    } 
    if { [eq $type varchar] } {
        return $lengthvar
    } else {
    error "Col \"$col_name\" is not type varchar it is type \"$type\""
    }
}

doc db_col_varchar_length {
    Parent db
    Examples {
	# A table sales_orders has column delivery_address1 type varchar(100)
	% db_col_varchar_length sales_orders delivery_address1
	100
    }
}
