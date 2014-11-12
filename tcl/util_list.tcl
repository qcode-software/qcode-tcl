namespace eval qc {
    namespace export lshift lunshift lintersect lexclude lexclude2 lunion ldelete lmove lunique lequal lsort_using in lpage ltotitle list2csv lconcat lsum laverage lreplace_values lapply
}

proc qc::lshift { stack } {
    #| Return leftmost value from list and remove it
    upvar 1 $stack list
    set value [lindex $list 0]
    set list [lrange $list 1 end]
    return $value 
}

proc qc::lunshift { stack value } {
    #| Adds $value as leftmost item in the list
    upvar 1 $stack list
    if { ![ info exists list ] } {
	set list {}
    }
    set list [linsert $list 0 $value]
}

global tcl_version
if { $tcl_version<8.5 } {
    proc lreverse { list } {
        #| List reverse for Tcl <8.5 
	set rlist {}
	foreach value $list {
	    set rlist [linsert $rlist 0 $value]
	}
	return $rlist
    }
    

proc qc::lintersect { a b } {
    #| Returns the intersection of 2 lists
    set a [lsort $a]
    set result {}
    foreach element $b {
	if { [lsearch -sorted -increasing $a $element] != -1 } {
	    lappend result $element
	}
    }
    return $result
}

proc qc::lexclude { list args } {
    #| Return $list with and values listed in $args excluded
    set result {}
    foreach elem $list {
	if { ![in $args $elem] } {
	    lappend result $elem
	}
    }
    return $result
}

proc qc::lexclude2 { list args } { 
    #| Alternative implementation of qc::lexclude
    foreach item $args {
	if { [set index [lsearch $list $item]]!=-1 } {
	    ldelete list $index
	}
    }
    return $list
}

proc qc::lunion { a b } {
    #| Return union of 2 lists
    set result [concat $a $b]
    return [lsort -unique $result]
}

proc qc::ldelete {listVar index} {
    #| Deletes item at $index of list
    upvar 1 $listVar list
    # Replace a deletion with null, much faster
    set list [lreplace [K $list [set list {}]] $index $index]
}

proc qc::lmove {list from to} {
    #| Move an element in a list from one place to another
    return [linsert [lreplace $list $from $from] $to [lindex $list $from]]
}

proc qc::lunique {list} {
    #| Returns a list of distinct list values
    set result {}
    foreach item $list {
	if {![info exists u($item)]} {
	    set u($item) {}
	    lappend result $item
	}
    }
    return $result
}

proc qc::lequal {a b} {
    #| Compare 2 list 
    # Author RS Tcl wiki
    if {[llength $a] != [llength $b]} {return 0}
    if {[lindex $a 0] == $a} {return [string equal $a $b]}
    foreach i $a j $b {if {![lequal $i $j]} {return 0}}
    return 1
} 

proc qc::lsort_using { list order } {
    #| Apply an arbitrary sort order to a list
    foreach item [lreverse $order] {
	foreach index [lsearch -all -exact $list $item] {
	    set list [lmove $list $index 0]
	}
    }
    return $list
}

# ::tcl::mathop::in has different argument sequence
#namespace import ::tcl::mathop::in
#namespace import ::tcl::mathop::ni

proc qc::in { list item } {
    #| Return 1 if $item appears in $list
    set list [lsort $list]
    if {[lsearch -sorted -increasing $list $item] == -1 } {
	return 0
    } else {
	return 1
    }
}

proc qc::lpage { list page_length } {
    #| Split list into sublists of length $page_length
    set lpage {}
    while { [llength $list]%$page_length != 0 || [llength $list]<$page_length} {
	lappend list ""
    }
    for { set line 0 } { $line < [llength $list] } { incr line $page_length } {
	lappend lpage [lrange $list $line [expr {$line + $page_length -1}]]
    }
    return $lpage
}

proc qc::ltotitle {list} {
    #| Make each word totitle excepting some industry specific acronyms
    if { [regexp {\"} $list] } {
	return $list
    } else {
	set new_list {}
	set upper {TV FM AM PVC BC DP ES CCTV TP&N GU10 SP&N MCB RCD AC DC}
	foreach word [split $list] {
	    if { [in $upper [upper $word]] } {
		lappend new_list [upper $word]
	    } else {
		lappend new_list [string totitle $word]
	    }
	}
	return [join $new_list]
    }
}

proc qc::list2csv {list {comma ,}} {
    #| Convert list to CSV (use of comma can be overridden)
    set out ""
    set separator {}
    foreach field $list {
	if { [string first $comma $field]==-1
             && [string first \" $field]==-1
             && [string first \n $field]==-1
         } {
	    append out $separator$field
	} else {
	    append out $separator\"[string map [list \" \"\"] $field]\"
	}
	set separator $comma
    }
    return $out
}

proc qc::lconcat {listVar list} {
    #| Concatenate list onto supplied listVar
    upvar $listVar var
    set var [concat $var $list]
}

proc qc::lsum {list} {
    #| Return sum of all list items
    set total 0
    foreach number $list {
	set total [expr {$total+$number}]
    }
    return $total
}

proc qc::laverage {list} {
    #| Returns average of all list elements
    return [expr {double([lsum $list])/[llength $list]}]
}

proc qc::lreplace_values {list find replace} {
    #| Replace any occurrence of $find in $list with $replace
    set index [lsearch -exact $list $find]
    while { $index!=-1 } {
	set list [lreplace $list $index $index $replace]
	set index [lsearch -exact $list $find]
    }
    return $list
}

proc qc::lapply { func list } {
    #| Apply the named procedure to all elements in the list and return a list of the results
    set result {}
    foreach item $list {
        lappend result [$func $item]
    }
    return $result
}

