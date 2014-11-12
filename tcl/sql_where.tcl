namespace eval qc {
    namespace export sql_where sql_where_like sql_where_cols_start sql_where_col_starts sql_where_combo sql_where_compare sql_where_compare_set sql_where_or sql_where_word_in
}

proc qc::sql_where { args } {
    qc::args $args -nocase -type "" -- args
    #| Construct part of SQL WHERE clause using varNames
    #| in a pass-by-name list or a dict.
    #| Any empty values or non-existent variables are ignored
    set dict [qc::args2dict $args]
    set list {}
    foreach {name value} $dict {
        if { [ne $value ""] } {
         if { [string equal $value NULL] } {
                lappend list "$name IS NULL"
         } elseif { [string equal $value "NOT NULL"] } {
                lappend list "$name IS NOT NULL"
         } else {
                if { [info exists nocase] } {
                 lappend list "lower($name)=lower([db_quote $value $type])"
                } else {
                 lappend list "$name=[db_quote $value $type]"
                }
         }
        }
    }
    if { [llength $list]==0 } {
        return true
    } else {
        return [join $list " and "]
    }
}

proc qc::sql_where_like { args } {
    #| Construct part of SQL WHERE clause using varNames
    #| in a pass-by-name list or a dict.
    #| Any empty values or non-existent variables are ignored
    set dict [args2dict $args]
    set list {}
    foreach {name value} $dict {
	if { [info exists value] && [ne $value ""] } {
	    foreach word [split $value] {
		lappend list "$name ~~* [db_quote "%$word%"]"
	    }
	}
    }
    if { [llength $list]==0 } {
	return true
    } else {
	return [join $list " and "]
    }
}

proc qc::sql_where_cols_start { args } {
    #| Construct part of SQL WHERE clause using varNames
    #| corresponding to column names with a regexp matching the
    #| start of the col value.
    #| Any empty values or non-existent variables are ignored
    qc::args $args -nocase -- args
    set dict [args2dict $args]
    if { [info exists nocase] } {
	set operator ~*
    } else {
	set operator ~
    }
    set list {}
    foreach {name value} $dict {
	if { [info exists value] && [ne $value ""] } {
	    lappend list "$name $operator [db_quote "^[db_escape_regexp $value]"]"
	}
    }
    if { [llength $list]==0 } {
	return true
    } else {
	return [join $list " and "]
    }
}

proc qc::sql_where_col_starts { args } {
    #| Construct part of SQL WHERE clause with a regexp matching 
    #| any given values to the start of the col value.
    #| Any empty values or non-existent variables are ignored
    qc::args $args -nocase -not -- col_name args
    if { [info exists nocase] } {
	set operator ~*
    } else {
	set operator ~
    }
    if { [info exists not] } {
	set operator "!$operator"
	set logic and
    } else {
	set logic or
    }
    set list {}
    foreach value $args {
	if { [ne $value ""] } {
	    lappend list "$col_name $operator [db_quote "^[db_escape_regexp $value]"]"
	}
    }
    if { [llength $list]==0 } {
	return true
    } else {
	return ([join $list " $logic "])
    }
}

proc qc::sql_where_combo { col_name value } {
    if { [ne $value ""] } {
	return "$col_name ~* [db_quote "^[db_escape_regexp $value]"]"
    } else {
	return true
    }
}

proc qc::sql_where_compare { args } {
    # WACKY
    # list of varNames
    # assume operator is stored in names variable named varName_op
    set list {}
    foreach name $args {
	if { ![regexp {^([^.]+)\.([^.]+)$} $name sql_name relation var_name] } {
	    set sql_name $name
	    set var_name $name
	}
	qc::upcopy 1 $var_name value
	qc::upcopy 1 "${var_name}_op" operator
	if { [info exists value] && [info exists operator] && [ne $value ""] } {
	    # check operator
	    if { ![in [list < = > <> <= >=] $operator] } { error "Unknown operator $operator" }
	    if { [eq $value NULL] && [eq $operator =] } {
		lappend list "$sql_name IS NULL"
	    } else {
		lappend list "${sql_name}${operator}[db_quote $value]"
	    }
	}
    }
    if { [llength $list]==0 } {
	return true
    } else {
	return [join $list " and "]
    }
}

proc qc::sql_where_compare_set { args } {
    qc::args $args -type "" --  name operator value
    if { [ne $value ""] } {
	# check operator
	if { ![in [list < = > <> <= >=] $operator] } { error "Unknown operator $operator" }
	if { [eq $value NULL] && [eq $operator =] } {
	    return "$name IS NULL"
	} else {
	    return "${name}${operator}[db_quote $value $type]"
	}
    } else {
	return true
    }
}

proc qc::sql_where_or { args } {
    #| Return a SQL where clause. Any empty values or non-existent variables are ignored
    set dict [args2dict $args]
    set list {}
    foreach {name value} $dict {
	if { [ne $value ""] } {
	    if { [string equal $value NULL] } {
		lappend list "$name IS NULL"
	    } elseif { [string equal $value "NOT NULL"] } {
		lappend list "$name IS NOT NULL"
	    } else {
		lappend list "$name=[db_quote $value]"
	    }
	}
    }
    if { [llength $list]==0 } {
	return true
    } else {
	return ([join $list " or "])
    }
}

proc qc::sql_where_word_in { name value } {
    #| Deprecated proc name - use qc::sql_where_words_in 
    return [sql_where_words_in $name $value]
}

proc qc::sql_where_phrase_words_in { args } {
    #| Where clause to match the words in each phrase
    qc::args $args -all -- name args
    set list {}
    foreach phrase $args {
	lappend list "([qc::sql_where_words_in $name $phrase])"
    }
    if { [llength $list] > 0 } {
        if { [info exists all] } {
            return "[join $list " and "]"
        } else {
            return "([join $list " or "])"
        }
    } else {
        return true
    }
}

proc qc::sql_where_words_in { name phrase } {
    #| Where clause to match all words in the phrase in any order.
    set list {}
    if { [ne $phrase ""] } {
        foreach word [split $phrase] {
            lappend list "$name ~ [db_quote "( |^)[db_escape_regexp $word]( |$)"]"
	}
        return [join $list " and "]
    } else {
	return true
    } 
}

proc qc::sql_where_phrases_in { args } {
    #| Where clause to evaluate to true if $phrase occurrs in sql expression $name
    qc::args $args -all -- name args
    set list {}
    foreach phrase $args {
        if { [ne $phrase ""] } {
            lappend list "$name ~ [db_quote "( |^)[db_escape_regexp $phrase]( |$)"]"
        }
    }
    if { [llength $list] > 0 } {
        if { [info exists all] } {
            return [join $list " and "]
        } elseif { [llength $list] > 1 } {
            return ([join $list " or "])
        } else {
            return [lindex $list 0]
        }
    } else {
        return true
    }
}

