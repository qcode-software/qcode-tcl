package provide qcode 1.12
package require doc
namespace eval qc {}

proc qc::lshift { stack } {
    #| Return leftmost value from list and remove it
    upvar 1 $stack list
    set value [lindex $list 0]
    set list [lrange $list 1 end]
    return $value 
}

doc qc::lshift {
    Description {
        Return leftmost value from list and remove it
    }
    Usage {
        qc::lshift listVar
    }
    Examples {
        % proc call { args } {
        set proc_name [qc::lshift args]
        return [$proc_name {*}$args]
        }
        % call qc::base 16 15
        F
    }
}

proc qc::lunshift { stack value } {
    #| Adds $value as leftmost item in the list
    upvar 1 $stack list
    if { ![ info exists list ] } {
	set list {}
    }
    set list [linsert $list 0 $value]
}

doc qc::lunshift {
    Description {
        Adds $value as leftmost item in the list
    }
    Usage {
        qc::lunshift listVar value
    }
    Examples {
        % set items [list a b c d]
        a b c d
        % qc::lunshift items z
        z a b c d
        % set items
        z a b c d
    }
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
    doc qc::lreverse {
        Description {
            Returns list in reverse order
        }
        Usage {
            qc::lreverse list
        }
        Examples {
            % set items [list a b c d]
            a b c d
            % qc::lreverse $items
            d c b a
        }
    }
    proc lassign {list args} {
        #| List assign for Tcl <8.5 
	foreach value $list variableName $args {
	    upset 1 $variableName $value
	}
    }
    doc qc::lassign {
        Description {
            Assigns the supplied vars to the corresponding list item values
        }
        Usage {
            qc::lassign list var ?var? ?var? ?var? ...
        }
        Examples {
            % set items [list Angus Jamison Jock Mackay]     
            Angus Jamison Jock Mackay
            % lassign $items firstname middlename1 middlename2 surname
            % set firstname
            Angus
            % set surname
            Mackay
        }
    }   
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

doc qc::lintersect {
    Description {
        Returns the intersection of 2 lists
    }
    Usage {
        qc::lintersect list list
    }
    Examples {
        % set list1 [list a b c d e]
        a b c d e
        % set list2 [list d e f g h]
        d e f g h
        % qc::lintersect $list1 $list2
        d e
    }
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

doc qc::lexclude {
    Description {
        Return $list with and values listed in $args excluded
    }
    Usage {
        qc::lexclude list value ?value? ?value? ...
    }
    Examples {
        % set items [list Angus Jamison Jock Mackay]     
        Angus Jamison Jock Mackay
        % qc::lexclude $items "Jock" "Mackay"
        Angus Jamison
        % set items [list 1 2 2 2 3 4 4 4 4]
        1 2 2 2 3 4 4 4 4
        % qc::lexclude $items 2
        1 3 4 4 4 4
    }
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

doc qc::lunion {
    Description {
        Return union of 2 lists
    }
    Usage {
        qc::lunion list list
    }
    Examples {
        % set l1 [list 4 3 3 2 1]
        4 3 3 2 1
        % set l2 [list 1 3 5 7]
        1 3 5 7
        % qc::lunion $l1 $l2
        1 2 3 4 5 7
    }
}

proc qc::ldelete {listVar index} {
    #| Deletes item at $index of list
    upvar 1 $listVar list
    # Replace a deletion with null, much faster
    set list [lreplace [K $list [set list {}]] $index $index]
}

doc qc::ldelete {
    Description {
        Deletes item at $index of list
    }
    Usage {
        qc::ldelete listVar index
    }
    Examples {
        % set items [list "Mr" "Angus" "Jamison"]
        Mr Angus Jamison
        % qc::ldelete items 0
        Angus Jamison
        % set items
        Angus Jamison
    }
}

proc qc::lmove {list from to} {
    #| Move an element in a list from one place to another
    return [linsert [lreplace $list $from $from] $to [lindex $list $from]]
}

doc qc::lmove {
    Description {
        Move an element in a list from one place to another
    }
    Usage {
        qc::lmove list from_index to_index
    }
    Examples {
        % set items [list a b d c e]
        a b d c e
        % qc::lmove $items 2 3
        a b c d e
    }
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

doc qc::lunique {
    Description {
        Returns a list of distinct list values
    }
    Usage {
        qc::lunique list
    }
    Examples {
        % set items [list 1 1 1 2 2 3 4 5 5 6 6 6 6]
        1 1 1 2 2 3 4 5 5 6 6 6 6
        % qc::lunique $items
        1 2 3 4 5 6
    }
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

doc qc::lsort_using {
    Description {
        Apply an arbitrary sort order to a list
    }
    Usage {
        qc::lsort_using list order
    }
    Examples {
        % set items [list R W E Q]
        R W E Q
        % qc::lsort_using $items {Q W E R T Y}
        Q W E R
    }
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

doc qc::in {
    Description {
        Return 1 if $item appears in $list
    }
    Usage {
        qc::in list item
    }
    Examples {
        % set banned_hosts [list "polaris" "trident" "poseiden"]
        polaris trident poseiden
        % qc::in $banned_hosts "arctic"
        0
        % qc::in $banned_hosts "trident"
        1
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

doc qc::lpage {
    Description {
        Split list into sublists of length $page_length
    }
    Usage {
        qc::lpage list page_length
    }
    Examples {
        % set items [list {code AA sales 9.99} {code BB sales 0} {code CC sales 100} {code DD sales 32} {code EE sales 65}]
        {code AA sales 9.99} {code BB sales 0} {code CC sales 100} {code DD sales 32} {code EE sales 65}
        % set page_content [qc::lpage $items 3]
        {{code AA sales 9.99} {code BB sales 0} {code CC sales 100}} {{code DD sales 32} {code EE sales 65} {}}
        % set pages [llength $page_content]
        2
        % for {set page 1} {$page<=$pages} {incr page} {
            puts "[lindex $page_content [expr {$page-1}]]"
            puts "Page $page of $pages"
            }
        {code AA sales 9.99} {code BB sales 0} {code CC sales 100}
        Page 1 of 2
        {code DD sales 32} {code EE sales 65} {}
        Page 2 of 2
    }
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

doc qc::ltotitle {
    Description {
        Make each word totitle excepting some industry specific acronyms
    }
    Usage {
        qc::ltotitle list
    }
    Examples {
        % set items [list jeff tom dave KERRY CCTV]
        jeff tom dave KERRY CCTV
        % qc::ltotitle $items
        Jeff Tom Dave Kerry CCTV
    }
}

proc qc::list2csv {list {comma ,}} {
    #| Convert list to CSV (use of comma can be overridden)
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

doc qc::list2csv {
    Description {
        Convert list to CSV (use of comma as delimiter can be overridden)
    }
    Usage {
        qc::list2csv list ?delimiter?
    }
    Examples {
        % set items [list "jeff" "tom" "dave" "KERRY"]
        jeff tom dave KERRY
        % qc::list2csv [qc::ltotitle $items]
        Jeff,Tom,Dave,Kerry
        % qc::list2csv [qc::ltotitle $items] |
        Jeff|Tom|Dave|Kerry
    }
}

proc qc::lconcat {listVar list} {
    #| Concatenate list onto supplied listVar
    upvar $listVar var
    set var [concat $var $list]
}

doc qc::lconcat {
    Description {
        Concatenate list onto supplied listVar
    }
    Usage {
        qc::lconcat listVar list
    }
    Examples {
        % set l1 [list 4 3 3 2 1]
        4 3 3 2 1
        % set l2 [list 1 3 5 7]
        1 3 5 7
        % qc::lconcat l1 $l2
        4 3 3 2 1 1 3 5 7
        % set l1
        4 3 3 2 1 1 3 5 7
    }
}

proc qc::lsum {list} {
    #| Return sum of all list items
    set total 0
    foreach number $list {
	set total [expr {$total+$number}]
    }
    return $total
}

doc qc::lsum {
    Description {
        Returns the sum of a list of numeric items.
    }
    Usage {
        qc::lsum list
    }
    Examples {
        % set items [list 1 2 1 100]
        1 2 1 100
        % qc::lsum $items
        104
    }
}

proc qc::laverage {list} {
    #| Returns average of all list elements
    return [expr {double([lsum $list])/[llength $list]}]
}

doc qc::laverage {
    Description {
        Returns average of all list elements
    }
    Usage {
        qc::laverage list
    }
    Examples {
        % set items [list 1 2 1 100]
        1 2 1 100
        % qc::laverage $items
        26.0
    }
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

doc qc::lreplace_values {
    Description {
        Replace any occurrence of $find in $list with $replace
    }
    Usage {
        qc::lreplace_values list find replace
    }
    Examples {
        % set items [list 9.99 8.49 6.49 NULL 10.99 NULL 1.99]
        9.99 8.49 6.49 NULL 10.99 NULL 1.99
        % qc::lreplace_values $items NULL 0
        9.99 8.49 6.49 0 10.99 0 1.99
    }
}

proc qc::lapply { func list } {
    #| Apply the named procedure to all elements in the list and return a list of the results
    set result {}
    foreach item $list {
        lappend result [$func $item]
    }
    return $result
}

doc qc::lapply {
    Description {
        Apply the named procedure to all elements in the list and return a list of the results
    }
    Usage {
        qc::lapply func list
    }
    Examples {
        % proc employee_get { id } {
            set employee_dict [dict create 1 Kagan 2 Boot 3 Bolton 4 Scheunemann 5 Sagan]
            return [dict get $employee_dict $id]
        }
        % set employee_subset [list 1 3 4]
        1 3 4
        % qc::lapply employee_get $employee_subset
        Kagan Bolton Scheunemann
    }
}
