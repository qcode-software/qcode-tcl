package provide qcode 1.0
package require doc
namespace eval qc {}

proc qc::lpush { stack value } {
    upvar 1 $stack list
    lappend list $value
}

proc qc::lpop { stack } {
    upvar 1 $stack list
    set value [lindex $list end]
    set list [lrange $list 0 [expr [llength $list]-2]]
    return $value
}

proc qc::lshift { stack } {
    upvar 1 $stack list
    set value [lindex $list 0]
    set list [lrange $list 1 end]
    return $value 
}

proc qc::lunshift { stack value } {
    upvar 1 $stack list
    if { ![ info exists list ] } {
	set list {}
    }
    set list [linsert $list 0 $value]
}

global tcl_version
if { $tcl_version<8.5 } {
    proc lreverse { list } {
	set rlist {}
	foreach value $list {
	    set rlist [linsert $rlist 0 $value]
	}
	return $rlist
    }
    proc lassign {list args} {
	foreach value $list variableName $args {
	    upset 1 $variableName $value
	}
    }   
}

proc qc::lintersect { a b } {
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
    set result {}
    foreach elem $list {
	if { ![in $args $elem] } {
	    lappend result $elem
	}
    }
    return $result
}

proc qc::lexclude2 { list args } { 
    foreach item $list {
	if { [set index [lsearch $list $item]]!=-1 } {
	    ldelete list $index
	}
    }
}

proc qc::lunion { a b } {
    set result [concat $a $b]
    return [lsort -unique $result]
}

proc qc::ldelete {listVar index} {
    upvar 1 $listVar list
    # Replace a deletion with null, much faster
    set list [lreplace [K $list [set list {}]] $index $index]
}

proc qc::lmove {list from to} {
    # move an element in a list from one place to another
    return [linsert [lreplace $list $from $from] $to [lindex $list $from]]
}

proc lunique {list} {
    set result {}
    foreach item $list {
	if {![info exists u($item)]} {
	    set u($item) {}
	    lappend result $item
	}
    }
    return $result
}

proc qc::lsort_using { list order } {
    foreach item [lreverse $order] {
	foreach index [lsearch -all -exact $list $item] {
	    set list [lmove $list $index 0]
	}
    }
    return $list
}

proc qc::in { list item } {
    set list [lsort $list]
    if {[lsearch -sorted -increasing $list $item] == -1 } {
	return 0
    } else {
	return 1
    }
}

proc qc::lpage { list page_length } {
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
    # Make each word totitle
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
    set out ""
    set separator {}
    foreach field $list {
	if { [string first $separator $field]==-1 && [string first \" $field]==-1 } {
	    append out $separator$field
	} else {
	    append out $separator\"[string map [list \" \"\"] $field]\"
	}
	set separator $comma
    }
    return $out
}

proc lconcat {listVar list} {
    upvar $listVar var
    set var [concat $var $list]
}

proc flatten {list} {
    set newList {}
    foreach e $list {foreach ee $e {lappend newList $ee}}
    return $newList
}

proc lsum {list} {
    set total 0
    foreach number $list {
	set total [expr {$total+$number}]
    }
    return $total
}

proc laverage {list} {
    return [expr {double([lsum $list])/[llength $list]}]
}

proc lreplace_values {list find replace} {
    set index [lsearch -exact $list $find]
    while { $index!=-1 } {
	set list [lreplace $list $index $index $replace]
	set index [lsearch -exact $list $find]
    }
    return $list
}

proc lapply { func list } {
    set result {}
    foreach item $list {
        lappend result [$func $item]
    }
    return $result
}



