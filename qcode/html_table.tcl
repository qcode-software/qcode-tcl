package provide qcode 1.6
package require doc
namespace eval qc {}

doc qc::html_table {
    Usage {
	html_table ?dict?<br>
	html_table ~ varName varName varName ...
    }
    Description {
	Create an HTML table.<br>
	Some options have special meaning:-

	<h3>cols</h3>
	<div class="indent">
	cols is a list of col dicts.Each dict specifies properties for the column.
	Some keys in each col have special meaning:-
	
	<h4>label</h4>
	If the label key exists and thead is undefined then a thead is created using the labels as column headings

	<h4>class</h4>
	Specifies the css class attribute of the col element.<br>
	The col class may be used to format the column cells.If a feature is not available through CSS then cell contents may be formatted.<br>
	E.g. clsMoney is used to call format_money<br>
	Defined for clsMoney,clsNumber,clsInteger,clsBool

	<h4>width</h4>
	The will set the width in the style attribute for the col element.

	<h4>format</h4>
	Use the function specified to format all the cells in that column including the tfoot cells.

	<h4>thClass</h4>
	Used to specify the class to apply to the corresponding th element in thead
	
	<h4>tfoot</h4>
	Specifies the value to use in the tfoot cell for that column
	</div>
	
	<h3>thead</h3>
	<div class="indent">
	A list of lists that is used to populate the thead
	</div>

	<h3>tbody</h3>
	<div class="indent">
	A list of lists that is used to populate the tbody
	</div>

	<h3>tfoot</h3>
	<div class="indent">
	A list of lists that is used to populate the tfoot
	</div>

	<h3>table</h3>
	<div class="indent">
	A <proc>table</proc> used to create the table.<br>
	If no column labels are specified then use the column keys.<br>
	Map the data in the table to the tbody using the column names.
	</div>

	<h3>qry</h3>
	<div class="indent">
	A sql query that is used to create the table.<br>
	The column names become column labels and the query results are shown in the tbody.
	</div>

	<h3>rowClasses</h3>
	<div class="indent">
	A list of css class names that will be repeatedly applied to tbody rows.
	</div>

	<h3>scrollHeight</h3>
	<div class="indent">
	Controls the height of the view port used to scroll the table with fixed headers.
	</div>	
    }
    Examples {
	% set tbody {
	    {"Jimmy Tarbuck" 23.56}
	    {"Des O'Conner"  15.632}
	    {"Bob Monkhouse" 56.1}
	}
	% html_table tbody $tbody
	<table>
	<tbody>
	<tr>
	<td>Jimmy Tarbuck</td>
	<td>23.56</td>
	</tr>
	<tr>
	<td>Des O'Conner</td>
	<td>15.632</td>
	</tr>
	<tr>
	<td>Bob Monkhouse</td>
	<td>56.1</td>
	</tr>
	</tbody>
	</table>

	% set cols {
	    {label Name width 200}
	    {label Balance width 100 class clsMoney}
	}
	% html_table cols $cols tbody $tbody
	or
	% html_table ~ cols tbody
	<table>
	<colgroup>
	<col style="width:200">
	<col class="clsMoney" style="width:100">
	</colgroup>
	<thead>
	<tr>
	<th>Name</th>
	<th>Balance</th>
	</tr>
	</thead>
	<tbody>
	<tr>
	<td>Jimmy Tarbuck</td>
	<td>23.56</td>
	</tr>
	<tr>
	<td>Des O'Conner</td>
	<td>15.63</td>
	</tr>
	<tr>
	<td>Bob Monkhouse</td>
	<td>56.10</td>
	</tr>
	</tbody>
	</table>
    }   
}

proc qc::html_table { args } {
    set argnames [args2vars $args]
    # Special args are:- cols thead tbody tfoot table qry rowClasses scrollHeight sortable
    # Some col keys have special meaning :- label class format thClass tfoot sum

    if { [info exists sortCols] } {
	default sortable yes
    } else {
	default sortable no
    }
    if { [true $sortable] && [form_var_exists sortCols] } {
	set sortCols [form_var_get sortCols]
    }
   
    
    # QRY
    if { [info exists qry] && ![info exists table] && ![info exists tbody] } {
	set table [qc::db_select_table [qc::db_qry_parse $qry 1]]	    
    }
    # cols from table
    if { [info exists table] } {
	default cols {}
	set cols [qc::html_table_cols_from_table table $cols]
    }
    # sortable Header
    if { [info exists cols] && [true $sortable] && ![info exists thead] } {
	default sortCols ""
	set thead [qc::html_table_sort_header $cols $sortCols]
    }
    # Highlight th sorted
    if { [info exists cols] && [info exists sortCols] } {
	set index [qc::ldict_search cols name [lindex $sortCols 0]]
	if { $index !=-1 } {ldict_set cols $index thClass clsSorted}
    }
    # thead from labels
    if { [info exists cols] && [qc::html_table_wants_col_labels $cols] && ![info exists thead] } {
	set thead [qc::html_table_thead_from_cols $cols]
    }

    # tbody from table
    if { [info exists table] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_table $table $cols]
    }
    # tbody from data
    if { [info exists data] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_ldict $data $cols]
    }
    # format tbody
    if { [info exists tbody] && [info exists cols] && [qc::html_table_wants_format $cols] } { 
	set tbody [qc::html_table_format $tbody $cols]
    }
    # tfoot sum
    if { [info exists cols] && [qc::html_table_wants_sum $cols] } {
	if { [info exists tbody] } {
	    set tfoot [qc::html_table_tfoot_sums $cols tbody]
	}
    }
    # format tfoot
    if { [info exists tfoot] && [info exists cols] && [qc::html_table_wants_format $cols] } { 
	set tfoot [qc::html_table_format $tfoot $cols]
    }
    # Write table tag
    set html [qc::html_tag table {*}[dict_from {*}[lexclude $argnames height cols thead tbody tfoot data table rowClasses qry scrollHeight sortable]]]

    append html \n
    # Create colgroup and col children
    if { [info exists cols]} {
        append html [qc::html_table_colgroup $cols]
    }
    # Create thead
    if { [info exists thead] } {
        append html "<thead>\n"
        foreach row $thead {
	    if { [info exists cols]} {
		append html [qc::html_table_row_head $row $cols]
	    } else {
		append html [qc::html_table_row_head $row]
	    }
        }
        append html "</thead>\n"
    }
    # Create tbody
    if { [info exists tbody] } {
        append html "<tbody>\n"
	set rowNumber 0
        foreach row $tbody {
	    if { [info exists rowClasses] } {
		set rowClass [lindex $rowClasses [expr {$rowNumber%[llength $rowClasses]}]]
	    } else {
		set rowClass {}
	    }
	    append html [qc::html_table_row $row $rowClass]
	    incr rowNumber
        }
        append html "</tbody>\n"
    }
    # Create tfoot
    if { [info exists tfoot] } {
        append html "<tfoot>\n"
	foreach row $tfoot {
	    append html [qc::html_table_row $row]
        }
        append html "</tfoot>\n"
    }
    append html "</table>\n"

    # Scrollable - vertical
    if { [info exists scrollHeight] } {
	set div_style ""
	set div_class [list clsScroll]
	if { [lower $scrollHeight] eq "max" } {
	    lappend div_class dynamicResize
	} else {
	    set div_style [style_set $div_style height ${scrollHeight}px]
	}	

	set html [html div $html class $div_class style $div_style]
    }

    return $html
}

proc qc::html_table_row { row {rowClass ""} } {
    if { $rowClass == "" } {
	set html "<tr>\n"
    } else {
	set html "<tr class=\"$rowClass\">\n"
    }
    foreach cell $row {
	append html "<td>$cell</td>\n"
    }
    append html "</tr>\n"
    return $html 
}

proc qc::html_table_row_head { row {cols ""} } {
    # look for thClass in col config
    set html "<tr>\n"
    for {set i 0} {$i<[llength $row]} {incr i} {
	set cell [lindex $row $i]
	set col [lindex $cols $i]
	if {[dict exists $col thClass]} {
	    append html "<th class=\"[dict get $col thClass]\">$cell</th>\n"
	} else {
	    append html "<th>$cell</th>\n"
	}
    }
    append html "</tr>\n"
    return $html 
}

proc qc::html_table_colgroup { cols } {
    # create the html for the colgroup
    # col elements wrapped in a colgroup
    set html "<colgroup>\n"
    foreach col $cols {
	if { [dict exists $col width] } {
	    if { [dict exists $col style] } {
		dict set col style [qc::style_set [dict get $col style] width [dict get $col width]]
	    } else {
		dict set col style "width:[dict get $col width]"
	    }
	}
	append html [html_tag col {*}[dict_exclude $col width label sum format tfoot thClass]]\n
    }
    append html "</colgroup>\n"
    return $html
}

proc qc::html_table_thead_from_cols {cols} {
    set thead {}
    set row {}
    foreach col $cols {
        if { [dict exists $col label] } {
            lappend row [dict get $col label]
        } else {
            lappend row ""
        }
    }
    lappend thead $row
    return $thead
}

proc qc::html_table_tfoot_sums {cols tbodyVar} {
    upvar 1 $tbodyVar tbody
    set tfoot {}
    set row {}
    for {set i 0} {$i < [llength $cols]} { incr i } {
	set col [lindex $cols $i]
        if { [dict exists $col sum] && [string is true [dict get $col sum]] } {
	    #lappend row [qc::ll_sum ll $i]
	    lappend row [qc::html_table_tbody_sum tbody $i]
	} elseif { [dict exists $col avg] && [string is true [dict get $col avg]] } {
	    # Average of numeric values
	    lappend row [qc::html_table_tbody_avg tbody $i]
	} elseif {[dict exists $col tfoot]} {
	    lappend row [dict get $col tfoot]
        } else {
            lappend row ""
        }
    }
    lappend tfoot $row
    return $tfoot
}

proc qc::html_table_wants_sum {cols} {
    # look for "sum yes" in any col
    foreach col $cols {
	if { [dict exists $col sum] && [string is true [dict get $col sum]] } {
	    return 1
	}
    }
    return 0
}

proc qc::html_table_wants_col_labels {cols} {
    # look through the list of cols to see if any of them
    # have used a "label text" pair to indicate a column heading
    foreach col $cols {
	if { [dict exists $col label] } {
	    return 1
	}
    }
    return 0
}

proc qc::html_table_wants_format {cols} {
    # look through the list of cols to see if any of them
    # have format or class set
    foreach col $cols {
	if { [dict exists $col format] || [dict exists $col class] } {
	    return 1
	}
    }
    return 0
}

proc qc::html_table_cols_from_table { tableVar cols } {
    # Create or update cols from table data structure
    # use table to set label and name if not already set in col
    upvar 1 $tableVar table
    set index 0
    foreach colname [lindex $table 0] col $cols {
	if { ![dict exists $col label] } {
	    dict set col label $colname
	}
	if { ![dict exists $col name] } {
	    dict set col name $colname
	}
	lappend newcols $col
    }
    # use first row of data for class
    set index 0
    foreach value [lindex $table 1] col $newcols {
	if { ![dict exists $col class] } {
	    if { [is_integer $value] } {
		dict set col class clsNumber
	    } elseif { [is_decimal $value] } {
		dict set col class clsMoney
	    }
	}
	lset newcols $index $col
	incr index
    }
    return $newcols
}

proc qc::html_table_tbody_from_ldict {ldict cols} {
    set tbody {}
    foreach dict $ldict {
	set row {}
	foreach col $cols {
	    set name [dict get $col name]
	    if { [dict exists $dict $name] } {
		lappend row [dict get $dict $name]
	    } else {
		lappend row {}
	    }
	}
	lappend tbody $row
    }
    return $tbody
}

proc qc::html_table_tbody_from_table {table cols} {
    set tbody {}
    set indices {}
    set keys [lindex $table 0]
    set col_names [ldict_values cols name]
    if { [eq $keys $col_names] } {
	# Special case 
	return [lrange $table 1 end]
    }
    foreach col  $col_names { 
	lappend indices [lsearch $keys $col]
    }
    foreach list [lrange $table 1 end] {
	set row {}
	foreach index $indices {
	    lappend row [lindex $list $index]
	}
	lappend tbody $row
    }
    return $tbody
}

proc qc::html_table_tbody_sum { tbodyVar index } {
    # Calculate the sum of cells in the column given by index
    set sum 0
    upvar 1 $tbodyVar tbody
    foreach list $tbody {
	set value [lindex $list $index]
	set value [ns_striphtml $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

proc qc::html_table_tbody_avg { tbodyVar index } {
    # Calculate the average value of cells in the column given by index
    set sum 0
    set count 0
    upvar 1 $tbodyVar tbody
    foreach list $tbody {
	set value [lindex $list $index]
	set value [ns_striphtml $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	    incr count
	}
    }
    if { $count>0 } {
	return [expr {double($sum)/$count}]
    } else {
	return ""
    }
}

proc qc::html_table_format {table cols} {
    # format columns based on the column class or column format
    foreach col $cols colIndex [.. 0 [llength $cols]] {
	dict2vars $col class format dp zeros sigfigs commify percentage
	if { [info exists class] } {
	    switch -glob -- $class {
		clsMoney* {default dp 2;default commify yes}
		clsInteger* {default dp 0;default commify yes}
		clsNumber* {default commify yes}
		clsBool* {default format format_bool}
		clsPerct {default percentage yes;default commify yes}
	    }
	}

	if { [info exists dp] || [info exists sigfigs] || [info exists zeros] || [info exists commify] || [info exists percentage]} {
	    default dp ""
	    default sigfigs ""
	    default commify no
	    default zeros yes
	    default percentage no
	    foreach rowIndex [.. 0 [llength $table]] {
		set cell [lindex $table $rowIndex $colIndex]
		# Can't find a way to test if the cell exists to prevent an error when trying to lset
		# Best try is to skip empty strings
		if { [eq $cell ""] } {continue}
 		lset table $rowIndex $colIndex [qc::html_table_format_cell_if_number $cell $dp $sigfigs $zeros $commify $percentage]
	    }
	}
	if { [info exists format] } {
	    foreach rowIndex [.. 0 [llength $table]] {
		set cell [lindex $table $rowIndex $colIndex]
		if { [eq $cell ""] } {continue}
		lset table $rowIndex $colIndex [$format $cell]
	    }
	}
    }
    return $table
}

proc qc::html_table_format_cell_if_number {html dp sigfigs zeros commify percentage} {
    if { [regexp {(<[^>]+>)([^<]+)(<[^>]+>)} $html] } {
	regsub -all {[][$\\]} $html {\\&} html
	regsub -all {(<[^>]+>)([^<]+)(<[^>]+>)} $html "\\1\[qc::html_table_format_if_number {\\2} {$dp} {$sigfigs} {$zeros} {$commify} {$percentage}]\\3" html
	return [subst $html]
    } elseif { [is_decimal $html] } {
	return [qc::html_table_format_if_number $html $dp $sigfigs $zeros $commify $percentage]
    } else {
	return $html
    }
}

proc qc::html_table_format_if_number {value dp sigfigs zeros commify percentage} {
    #| If value is a number then commify
    if { [is_decimal $value] } {
	if { [true $percentage] } {
	    set value [expr {$value*100}]
	}
	if { [info exists sigfigs] && [is_integer $sigfigs]} {
	    set value [sigfigs $value $sigfigs]
	}
	if { [info exists dp] && [is_integer $dp] } {
	    set value [round $value $dp]
	}
	if { !$zeros && $value==0 } {
	    set value ""
	}
	if { [true $commify] } {
	    set value [format_commify $value]
	} 
	if { [true $percentage] } {
	    set value $value%
	}
    }
    return $value
}

proc qc::html_tbody_row {cols} {
    set list {}
    foreach col $cols {
	if { [dict exists $col name] } {
	    set name [dict get $col name]
	    lappend list [upset 1 $name]
	} else {
	    lappend list ""
	}
    }
    return $list
}

proc qc::page_html_table { args } {
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
<div>$menu</div>
$table
"
    return $html
}