namespace eval qc {
    namespace export check checks
}

proc qc::check {args} {
    #| Check that the value of the local variable is of a given type or can be cast into that type.
    #| If the variable cannot be cast into the given type then throw an error of type USER.
    #| Use the error message given or a default message for the given type.
    #| The empty string is treated as a NULL value and always treated as valid unless NOT NULL is specified in types.
    switch -exact -- [llength $args] {
	0 - 
	1 {
	    return -code error "wrong#args: Should be varName type ?type? ?type? ?errorMessage?"
	}
	default {
	    set varName [lindex $args 0]
	    set args [lrange $args 1 end]
	}
    }
   
    # Parse
    array set alias [list INT INTEGER BOOL BOOLEAN STRING VARCHAR NZ NON_ZERO]
    set nulls yes
    set allow_html no
    set allow_creditcards yes
    set TYPES {}
    for {set index 0} {$index<[llength $args]} {incr index} {
	set TYPE [upper [lindex $args $index]]
	set type [lower $TYPE]
	set NEXT_TYPE [upper [lindex $args [expr {$index+1}]]]
	# This is an alias
	if { [info exists alias($TYPE)] } {
	    set TYPE $alias($TYPE)
	    set type [lower $TYPE]
	}
	# Creditcards not allowed in text fields by default
	if { [in {STRING VARCHAR} $TYPE] } {
	    set allow_creditcards no
	}
	# 
	if { $TYPE eq "NOT" && $NEXT_TYPE eq "NULL" } {
	    set nulls no
	    incr index 
	    continue
	} elseif { $TYPE eq "NOT" && $NEXT_TYPE eq "HTML" } {
	    set allow_html no
	    incr index 
	    continue
	} elseif {$TYPE eq "HTML"} {
	    set allow_html yes
	    continue
	} elseif { [in {NO NOT} $TYPE] && $NEXT_TYPE eq "CREDITCARDS" } {
	    set allow_creditcards no
	    incr index 
	    continue
	} elseif {$TYPE eq "CREDITCARDS"} {
	    set allow_creditcards yes
	    continue
	} elseif {$TYPE eq "CREDITCARD"} {
	    lappend TYPES CREDITCARD
	    set allow_creditcards yes
	    continue
	} elseif {[info commands "::qc::is::$type"] ne ""} {
	    lappend TYPES $TYPE
	    set n [llength [info args "::qc::is::$type"]]
	    if {$n>1} {
		set type_args($TYPE) [lrange $args [expr {$index+1}] [expr {$index+$n-1}]]
		incr index [expr {$n-1}]
	    }
	} elseif {[info commands "::qc::is::$type"] ne ""} {
	    lappend TYPES $TYPE
	    set n [llength [info args "::qc::is::$type"]]
	    if {$n>1} {
		set type_args($TYPE) [lrange $args [expr {$index+1}] [expr {$index+$n-1}]]
		incr index [expr {$n-1}]
	    }
	} elseif {$TYPE eq "PNZ"} {
	    lappend TYPES POS NZ
	    set nulls no
	} elseif {$TYPE eq "PRICE"} {
	    lappend TYPES DECIMAL PNZ 
	    set nulls no
	} elseif {$TYPE eq "QTY"} {
	    lappend TYPES INTEGER PNZ
	    set nulls no
	} elseif {$index>0 && $index==[llength $args]-1} {
	    set errorMessage [lindex $args end]
	} else {
	    error "Don't know how to check $TYPE"
	}
    }

    upvar 1 $varName varValue
    # Exists
    if { ![info exists varValue] } {error "No such variable $varName"}
    # NULLs
    if { $nulls && [string equal $varValue ""] } {
	# NULL values are OK
	return true
    }
    if { !$nulls && [string equal $varValue ""] } {
	default errorMessage "$varName is empty"
	error $errorMessage {} USER
    }
    
    foreach TYPE $TYPES {
	set type [lower $TYPE]
	# Try to cast to the type specified if a proc exists
	if { [in {POS NZ} $TYPE] && ![qc::is decimal $varValue] } {
	    # Implied cast
	    qc::try {set varValue [qc::cast_decimal $varValue]}
	} elseif { [info commands "::qc::cast_$type"] ne "" } {
	    qc::try {
		if { [info exists type_args($TYPE)] } {
		    set varValue ["qc::cast_$type" $varValue {*}$type_args($TYPE)]
		} else {
		    set varValue ["qc::cast_$type" $varValue]
		}
	    }
	} elseif { [info commands cast_$type] ne "" } {
	    qc::try {
		if { [info exists type_args($TYPE)] } {
		    set varValue [cast_$type $varValue {*}$type_args($TYPE)]
		} else {
		    set varValue [cast_$type $varValue]
		}
	    }
	}
	# Check
	if {!([info exists type_args($TYPE)] && [info commands "::qc::is::$type"] ne "" && [qc::is $type $varValue {*}$type_args($TYPE)])
	    && 
	    !(![info exists type_args($TYPE)] && [info commands "::qc::is::$type"] ne "" && [qc::is $type $varValue])
            &&
            !([info exists type_args($TYPE)] && [info commands "::qc::is::$type"] eq "" && [qc::is $type $varValue {*}$type_args($TYPE)])
	    && 
	    !(![info exists type_args($TYPE)] && [info commands "::qc::is::$type"] eq "" && [qc::is $type $varValue])} {
	    # Failed
	    if { [info commands not_$type] ne "" } { 
		if { [info exists type_args($TYPE)] } {
		    default errorMessage [not_$type $varName $varValue {*}$type_args($TYPE)] 
		} else {
		    default errorMessage [not_$type $varName $varValue] 
		}
	    } else {
		default errorMessage "\"[html_escape $varValue]\" is not a valid $type for $varName"
	    }
	    error $errorMessage {} USER
	}
    }

    # HTML Markup OFF by default
    if { !$allow_html && [regexp {[<>]} $varValue] } {
	error "\"[html_escape $varValue]\" contains HTML which is not allowed for $varName" {} USER
    }

    # Check contains creditcard by default
    if { !$allow_creditcards && [contains_creditcard $varValue] } {
	error [expr {[info exists errorMessage] ? $errorMessage : "\"[html_escape $varValue]\" contains a creditcard number which is not allowed for $varName"}] {} USER
    }

    return true
}

proc qc::checks { body } {
    # Call check foreach line of checks in the format
    # varName type ?type? ?type? ?errorMessage?
    global errorInfo errorCode
    set errors {}
    set lines [split $body \n]
    foreach line $lines {
	set line [string trim $line]
	if { [ne $line ""] && [catch [list uplevel 1 [list check {*}$line]] errorMessage]==1 } {
	    if {$errorCode eq "USER"} {
		lappend errors $errorMessage
	    } else {
		error $errorMessage $errorInfo $errorCode
	    }
	}
    }
    if { [llength $errors] > 0 } {
	error [html_list $errors] {} USER
    }
}

