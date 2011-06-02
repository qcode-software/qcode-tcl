doc table {
    Title {Table Data Structure}
    Description {
	A table data structure is a list of lists. Every list has the same number of elements.<br>
	The first list contains the names used to identify each column.
	<p>
	The structure is similar to CSV files with column names on the first row.
	<p>
	The structure is used internally by the [doc_link db] and query results can be returned as a table using [doc_link db_select_table].<br>
	The proc [doc_link table_foreach] provides a convenient way to loop through the table.
    }
    Examples {
	% set table {
	    {firstname surname telephone}
	    {Jimmy Tarbuck 999}
	    {Des O'Conner 123}
	    {Bob Monkhouse 321}
	}
	%
	% set table2
	{user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}
    }
    
}

proc qc::table_foreach { table code } {
    # Loop through a table setting local variables with values in the row
    # named using the first row.
    # Then execute code given for every row.
    set keys [lindex $table 0]
    foreach list [lrange $table 1 end] {
	foreach key $keys value $list {
	    upset 1 $key $value
	}
	uplevel 1 $code
    }
}

doc table_foreach {
    Usage {table_foreach table code}
    Description {
	Loop through the [doc_link table] row-by-row. Use local variables with names corresponding to the column names in the table to hold the data for each row. Execute the code given for every data row.
    }
    Examples {
	% set table {
	    {firstname surname telephone}
	    {Jimmy Tarbuck 999}
	    {Des O'Conner 123}
	    {Bob Monkhouse 321}
	}
	% table_foreach $table {
	    append html "<li>$firstname $surname $telephone</li>"
	}
	% set html 
	<li>Jimmy Tarbuck 999</li><li>Des O'Conner 123</li><li>Bob Monkhouse 321</li>
    }	
}


proc qc::table2ldict { table } {
    #| Convert a table to an ldict (list of dicts)
    set ldict {}
    set keys [lindex $table 0]
    foreach list [lrange $table 1 end] {
	set dict {}
	foreach key $keys value $list {
	    lappend dict $key $value
	}
	lappend ldict $dict
    }
    return $ldict
}

proc qc::table2tbody_by_month { table from_year to_year } {
    set tbody {}
    set keys [lindex $table 0]
    array set data [table2array $table year month]
    
    foreach month [.. 1 12] {
	set row {}
	lappend row [date_month_shortname $from_year-$month-01]
	foreach year [.. $from_year $to_year] {
	    foreach varname [lexclude $keys year month] {
		lappend row [coalesce data($year,$month,$varname) ""]
	    }
	}
	lappend tbody $row
    }

    return $tbody
}

proc qc::table2array { table args } {
    array set data {}
    set keys [lindex $table 0]
    table_foreach $table {
	foreach varname [lexclude $keys {*}$args] {
	    set pkeys {}
	    foreach key $args {
		lappend pkeys [set $key]
	    }
	    lappend pkeys $varname
	    set pk [join $pkeys ,]
	    set data($pk) [set $varname]
	}
    }
    return [array get data]
}

proc qc::table_sum { table col_name } {
    set sum 0
    set col_index [lsearch [lindex $table 0] $col_name]
    foreach row_index [.. 1 [expr {[llength $table]-1}]] {
	set value [lindex $table $row_index $col_index]
	if { [is_decimal $value] } {
	    incr0 sum $value
	}
    }
    return $sum
}

proc qc::page_table { args } {
    #sql_sort -paging will have set the correct vars in caller's namespace
    args $args -limit ? -offset ? -count ? -- heading menu table
    default limit  [upset 1 limit]
    default offset [upset 1 offset]
    if { [uplevel 1 {info exists db_nrows}] } {
	default count [upset 1 db_nrows]
    }

    append heading " [expr {$offset +1}]...[expr {$offset+$count}]"

    if { $offset - $limit >=0 } {
	if { $menu ne "" } {
	    append menu " &nbsp;|&nbsp; "
	}
	append menu [qc::html_a_replace "Previous Page [expr {$offset-$limit+1}]...[expr {$offset}]" [url [url_here] offset [expr {$offset-$limit}]]]
    }
    if { $count == $limit } {
	if { $menu ne "" } {
	    append menu " &nbsp;|&nbsp; "
	}
	append menu [qc::html_a_replace "Next Page [expr {$offset+$limit+1}]...[expr {$offset+2*$limit}]" [url [url_here] offset [expr {$offset+$limit}]]]
    }

    set html "
<h3>$heading</h3>
<div class=\"clsMenu\">$menu</div>
$table
"
    return $html
}