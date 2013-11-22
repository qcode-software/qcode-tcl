package provide qcode 2.03
package require doc
namespace eval qc {
    namespace export ldict_* ldict2tbody
}

proc qc::ldict_set {ldictVar index key value} {
    #| Takes a list of dicts and sets the value for $key in the dict at $index
    upvar 1 $ldictVar ldict
    set dict [lindex $ldict $index]
    dict set dict $key $value
    lset ldict $index $dict
}

doc qc::ldict_set {
    Description {
        Takes a list of dicts and sets the value for $key in the dict at $index.
    }
    Usage {
        qc::ldict_set ldictVar index key value
    }
    Examples {
        % set dict_list [list {firstname John surname Mackay} {firstname Angus surname McNeil}]
        {firstname John surname Mackay} {firstname Angus surname McNeil}
        % qc::ldict_set dict_list 1 surname Jamison
        {firstname John surname Mackay} {firstname Angus surname Jamison}
    }
}

proc qc::ldict_sum { ldictVar key } {
    #| Traverse a dict list and sum all dict values for given key.
    # TODO: could be de-aolserverised, and perhaps should error if we try to add
    # non-decimal strings rather than return 0.
    set sum 0
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	set value [qc::strip_html $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

doc qc::ldict_sum {
    Description {
         Traverse a dict list and sum all dict values for given key.
    }
    Usage {
        qc::ldict_sum ldictVar key
    }
    Examples {
        1> set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
        {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
        2> qc::ldict_sum dict_list sales
        132.99
        3> qc::ldict_sum dict_list product
        0
    }
}

proc qc::ldict_max { ldictVar key } {
    set max {}
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	if { [string equal $max ""] } {
	    set max $value
	} else {
	    if { $value > $max } {
		set max $value
	    }
	}
    }
    return $max
}

doc qc::ldict_max {
    Description {
         Traverse a dict list and return the maximum of all dict values for given key.
         If non-numeric values are specified, the lexicographically greatest value is
         returned.
    }
    Usage {
        qc::ldict_max ldictVar key
    }
    Examples {
        % set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
        {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
        % qc::ldict_max dict_list sales
        99.99
        % qc::ldict_max dict_list product
        widget_c
    }
}

proc qc::ldict_values { ldictVar key } {
    #| Return a list of the values of this key
    #| in each dict in the ldict
    upvar 1 $ldictVar ldict
    set list {}
    foreach dict $ldict {
	lappend list [dict get $dict $key]
    }
    return $list
}

doc qc::ldict_values {
    Description {
         Return a list of the values of this key
    }
    Usage {
        qc::ldict_values ldictVar key
    }
    Examples {
        % set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
        {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
        %  qc::ldict_values dict_list product
        widget_a widget_b widget_c
    }
}

proc qc::ldict_exists {ldict key} {
    #| Return the first index of the dict that contains the the key $key
    set index 0
    foreach dict $ldict {
	if { [dict exists $dict $key]} {
	    return $index
	}
	incr index
    }
    return -1
}

doc qc::ldict_exists {
    Description {
         Return the first index of the dict that contains the the key $key
    }
    Usage {
        qc::ldict_exists ldict key
    }
    Examples {
        % set dict_list [list {firstname John surname Mackay} {firstname Andrew surname MacDonald}  {firstname Angus middlename Walter surname McNeil}]
        {firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus middlename Walter surname McNeil}
        % qc::ldict_exists $dict_list middlename
        2
    }
}

proc qc::ldict_search {ldictVar key value} {
    #| Return the first index of the dict that contains the value $value for the key $key
    upvar 1 $ldictVar ldict
    set index 0
    foreach dict $ldict {
	if { [dict exists $dict $key] && [dict get $dict $key]=="$value" } {
	    return $index
	}
	incr index
    }
    return -1
}

doc qc::ldict_search {
    Description {
        Return the first index of the dict that contains the value $value for the key $key
    }
    Usage {
        qc::ldict_search ldictVar key value
    }
    Examples {
        % set dict_list [list {product widget_a stock_level 99} {product widget_b stock_level 8} {product widget_c stock_level 0}]
        {product widget_a stock_level 99} {product widget_b stock_level 8} {product widget_c stock_level 0}
        % qc::ldict_search dict_list stock_level 0
        2
    }
}

proc qc::ldict_exclude { ldict key } {
    #| Remove all occurances of $key from the dicts in $ldict
    set newldict {}
    foreach dict $ldict {
	lappend newldict [dict_exclude $dict $key]
    }
    return $newldict
}

doc qc::ldict_exclude {
    Description {
        Remove all occurances of $key from the dicts in $ldict
    }
    Usage {
        qc::ldict_exclude ldict key
    }
    Examples {
        % set dict_list [list {firstname John surname Mackay} {firstname Andrew surname MacDonald}  {firstname Angus middlename Walter surname McNeil}]
        {firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus middlename Walter surname McNeil}
        %  qc::ldict_exclude $dict_list firstname
        {surname Mackay} {surname MacDonald} {middlename Walter surname McNeil}
    }
}

proc qc::ldict2tbody {ldict colnames} {
    #| Take a ldict and a list of col names to convert into tbody
    set tbody {}
    foreach dict $ldict {
	set row {}
	foreach colname $colnames {
	    if { [dict exists $dict $colname] } {
		lappend row [dict get $dict $colname]
	    } else {
		lappend row ""
	    }
	}
	lappend tbody $row
    }
    return $tbody
}

doc qc::ldict2tbody {
    Description {
        Take a ldict and a list of col names to convert into tbody
    }
    Usage {
        qc::ldict2tbody ldict colnames
    }
    Examples {
        set dict_list [list {code AAA product widget_a desc "Widget Type A" price 9.99 qty 10} {code BBB product widget_b desc "Widget Type B" price 8.99 qty 19} {code CCC product widget_c desc "Widget Type C" price 7.99 qty 1}]
        {code AAA product widget_a desc "Widget Type A" price 9.99 qty 10} {code BBB product widget_b desc "Widget Type B" price 8.99 qty 19} {code CCC product widget_c desc "Widget Type C" price 7.99 qty 1}
        % set tbody_cols [list product desc price]
        product desc price
        % set tbody [qc::ldict2tbody $dict_list $tbody_cols]
        {widget_a {Widget Type A} 9.99} {widget_b {Widget Type B} 8.99} {widget_c {Widget Type C} 7.99}
    }
}


