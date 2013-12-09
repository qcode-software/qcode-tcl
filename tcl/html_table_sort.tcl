package provide qcode 2.6.3
package require doc
namespace eval qc {
    namespace export html_table_sort html_table_sort_header
}

proc qc::html_table_sort {args} {
    qc::args2vars $args
    default id tScroll
    default height 600

    # QRY
    if { [info exists qry] && ![info exists tbody] } {
	if { ![info exists sortCols] } {
	    if { [qc::form_var_exists sortCols] } {
		set sortCols [qc::form_var_get sortCols]
	    } else {
		set sortCols [qc::sortcols_from_qry $qry]
	    }
	}
	# 
	regsub -nocase {order by (.+?)(offset|limit|$)} $qry "order by [sql_sort {*}$sortCols] \\2" qry
	set table [qc::db_select_table [qc::db_qry_parse $qry 1]]	    
    }
    # table 
    if { [info exists table] && ![info exists tbody] } {
	default cols {}
	set cols [qc::html_table_cols_from_table table $cols]
	set tbody [lrange $table 1 end]
    }
    # sortCols from cols
    if { ![info exists sortCols] } {
	if { [form_var_exists sortCols] } {
	    set sortCols [form_var_get sortCols]
	} else {
	    set sortCols [qc::sortcols_from_cols $cols]
	}
    }
    # Highlight th sorted
    if { [info exists cols] && [info exists sortCols] } {
	set index [qc::ldict_search cols name [lindex $sortCols 0]]
	if { $index !=-1 } {
	    qc::ldict_set cols $index thClass sorted
	}
    }
    set thead [qc::html_table_sort_header $cols $sortCols]

    set div_style ""
    set div_class [list scroll]
    if { [lower $height] eq "max" } {
	lappend div_class "dynamic-resize"
    } else {
	set div_style [style_set $div_style height ${height}px]
    }

    append html [html_tag div class $div_class style $div_style]
    append html [qc::html_table ~ class cols thead tbody tfoot data rowClasses id]    
    append html "</div>\n"

    return $html
}

proc qc::html_table_sort_header { cols sortCols } {
    set sortCols [qc::sortcols2dict {*}$sortCols]
    set row {}
    foreach col $cols {
	if { [dict exists $col label] } {
	    set label [dict get $col label]
	} else {
	    set label ""
	}
	if { [dict exists $col name] } {
	    if { [eq [dict get $col name] [lindex $sortCols 0]] } {
		# Primary sort col
		if { [eq [upper [dict get $sortCols [dict get $col name]]] DESC] } {
		    set sort_order DESC
		} else {
		    set sort_order ASC
		}
		if { [dict exists $col class] } {
		    set class [dict get $col class]
		} else {
		    set class ""
		}
		if { [eq $sort_order ASC] } {
		    if { "rank" in $class } {
			set indicator "Sorted Top to Bottom"
		    } elseif { "number" in $class || "money" in $class } {
			set indicator "Sorted Low to High"
		    } elseif { "date" in $class } {
			set indicator "Sorted Old to New"
		    } else {
			set indicator "Sorted A-Z"
		    }
		    lappend row "[html span $label class sort][html div $indicator class asc]"
		} else {
		    if { "rank" in $class } {
			set indicator "Sorted Bottom to Top"
		    } elseif { "number" in $class || "money" in $class } {
			set indicator "Sorted High to Low"
		    } elseif { "date" in $class } {
			set indicator "Sorted New to Old"
		    } else {
			set indicator "Sorted Z-A"
		    }
		    lappend row "[html span $label class sort][html div $indicator class desc]"
		}
	    } else {
		# Sortable col
		lappend row [html span $label class sort]
	    }
	} else {
	    # Not sortable col
	    lappend row $label
	}
    }
    lappend thead $row
    return $thead
}
