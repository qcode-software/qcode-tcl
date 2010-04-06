proc qc::check {args} {
    #| Check that the value of the local variable is of a given type or can be cast into that type.
    #| If the variable cannot be cast into the given type then throw an error of type USER.
    #| Use the error message given or a default message for the given type.
    #| The empty string is treated as a NULL value and always treated as valid unless NOT NULL is specified in types.
    if { [llength $args]==1 } {set args [lindex $args 0]}
    switch -exact -- [llength $args] {
	0 - 
	1 {
	    return -code error "wrong#args: Should be varName type ?type? ?type? ?errorMessage?"
	}
	2 {
	    lassign $args varName types
	}
	default {
	    set varName [lindex $args 0]
	    if { [string first " " [lindex $args end]]!=-1 } {
		set errorMessage [lindex $args end]
		set types [lrange $args 1 end-1]
	    } else {
		set types [lrange $args 1 end]
	    }
	}
    }

    # Translations
    set map {}
    lappend map "NOT NULL" NOT_NULL
    lappend map  PRICE "PNZ DECIMAL NOT_NULL"
    lappend map QTY "PNZ INT NOT_NULL"
    set types [string map $map [upper $types]]
    
    upvar 1 $varName varValue
    # Exists
    if { ![info exists varValue] } {error "No such variable $varName"}
    # NULL
    if {![in $types NOT_NULL] && [string equal $varValue ""] } {
	# Pass empty string NULL values
	return ""
    }
    
    foreach type $types {
	# Try to cast to the type specified
	try {
	    set varValue [check_cast $varValue $type]
	} {
	    # Failed to cast
	    default errorMessage [check_msg $varName $varValue $type] 
	    error $errorMessage {} USER
	}
	if { ![check_is_type $varValue $type] } {
	    default errorMessage [check_msg $varName $varValue $type] 
	    error $errorMessage {} USER
	}
    }
    return 1
}

doc check {
    Parent validate
    Usage {
	check varName type ?type? ?type? ?errorMessage?
    }
    Examples {
	% set order_date "23rd June 2007"
	% check order_date DATE
	2007-06-23
	# The check passes and order_date is cast into the type DATE
	% set order_date
	2007-06-23
	%
	% set amount mistake
	% check amount POS DECIMAL 
	"mistake" is not a positive value for amount
	%
	% set qty 1.2
	% check qty INT "Please enter a whole number of days."
	Please enter a whole number of days.
	%
	# NULL VALUES are valid unless excluded
	% set surname ""
	% check surname STRING30
	%
	% check surname STRING30 NOT NULL
	surname is empty
	%
	# String length for use with varchar(n) database columns
	# can be checked with STRINGn
	% set name "James Donald Alexander MacKenzie"
	check name STRING30
	"James Donald Alexander MacKenzie" is too long for name. The maximum length is 30 characters.
    }
}

proc qc::checks { body } {
    # Call check foreach line of checks in the format
    # varName type ?type? ?type? ?errorMessage?
    
    set errors {}
    set lines [split $body \n]
    foreach line $lines {
	set line [string trim $line]
	if { [ne $line ""] && [catch [list uplevel 1 check $line] errorMessage] } {
	    lappend errors $errorMessage
	}
    }
    if { [llength $errors] > 0 } {
	error [html_list $errors] {} USER
    }
}

doc checks {
    Description {
	Foreach line of checks in the format <code>varName type ?type? ?type? ?errorMessage?</code>, check that the value of the local variable is of the given type or can be cast into that type. The empty string is treated as a NULL value and always treated as valid unless NOT NULL is specified in types. If the variable cannot be cast into the given type then append a message to a list of errors. Use the error message given or a default message for the given type.
	<p>
	After all checks are complete throw an error if any checks failed using combined error message.	
    }
    Examples {
	% set order_date "never"
	% set delivery_name "James Donald Alexander MacKenzie"
	% set carrier ""
	% checks {
	    order_date DATE
	    delivery_name STRING30 NOT NULL
	    carrier NOT NULL "Please enter the carrier."
	}
	<ul>
	<li>"never" is not a valid date for order_date</li>
	<li>"James Donald Alexander MacKenzie" is too long for delivery_name. The maximum length is 30 characters.</li>
	<li>Please enter the carrier.</li>
	</ul>
	% 
    }
}

proc qc::check_cast {value type} {
    #| Try to cast the value into the specified type
    #| If the casting proc is not known look for a proc called "cast_$type"
    #| Say for a type PRODUCT_CODE look for a proc cast_product_code
    #| Otherwise return the value unchanged.
    set TYPE [string toupper $type]
    set type [string tolower $type]
    ## BOOLEAN
    if { [eq BOOL $TYPE] } {
	return [qc::cast_boolean $value]
    }
    ## INTEGERS
    if { [in {INT POS_INT NZ_INT PNZ_INT} $TYPE] } {
	return [qc::cast_integer $value]
    }
    ## DECIMAL
    if { [in {POS NZ DECIMAL POS_DECIMAL NZ_DECIMAL PNZ_DECIMAL} $TYPE] } {
	return [qc::cast_decimal $value]
    }
    ## DATES
    if { [eq DATE $TYPE] } {
	return [qc::cast_date $value]
    }
    ## UK POSTCODES
    if { [eq POSTCODE $TYPE] } {
	return [cast_postcode $value]
    }
    ## OTHER
    # Look for a proc named cast_$type
    if { [eq [info procs "::qc::cast_$type"] "::qc::cast_$type"] } {
	return ["::qc::cast_$type" $value]
    } 
    if { [eq [info procs "::cast_$type"] "::cast_$type"] } {
	return ["cast_$type" $value]
    } 
    return $value
}

proc qc::check_is_type {value type} {
    #| Check that the value is of the given type.
    #| If this is an unknown type then look for 
    #| a proc is_$type to check validity.
    set type [string tolower $type]
    set TYPE [string toupper $type]
    switch -regexp -- $TYPE {
	NOT_NULL      {return [ne $value ""]}
	BOOL          {return [is_boolean $value]}
	INT           {return [is_integer $value]}
	POS           {return [is_pos $value]}
	NZ            {return [is_non_zero $value]}
	PNZ           {return [is_pnz $value]}
	DECIMAL       {return [is_decimal $value]}
	DATE          {return [is_date $value]}
	EMAIL         {return [is_email $value]}
	POSTCODE      {return [is_postcode $value]}
	CREDITCARD    {return [is_creditcard $value]}
	{STRING[0-9]+} {
	    regexp {STRING([0-9]+)} $TYPE -> length
	    return [expr {[string length $value]<=$length}]
	}
    }
    # Look for a proc named is_$type
    if { [eq [info procs "::qc::is_$type"] "::qc::is_$type"] } {
	return ["::qc::is_$type" $value]
    } 
    if { [eq [info procs "::is_$type"] "::is_$type"] } {
	return ["::is_$type" $value]
    } 
    error "Don't know how to check \"$TYPE\""
}

proc qc::check_msg {varName varValue type} {
    #| Return the default error message for the given type.
    set db {}
    lappend db  NOT_NULL      "$varName is empty"
    lappend db 	INT           "\"$varValue\" is not an integer for $varName"
    lappend db 	POS           "\"$varValue\" is not a positive value for $varName"
    lappend db 	NZ            "$varName cannot be zero"
    lappend db 	PNZ           "\"$varValue\" is not a positive non-zero value for $varName"
    lappend db 	DECIMAL       "\"$varValue\" is not a decimal value for $varName"
    lappend db 	DATE          "\"$varValue\" is not a valid date for $varName"
    lappend db 	EMAIL         "\"$varValue\" is not a valid email address"
    lappend db 	POSTCODE      "\"$varValue\" is not a valid postcode"
    lappend db 	CREDITCARD    "\"$varValue\" is not a valid creditcard number."

    if { [regexp {STRING([0-9]+)} $type -> length] } {
	return "\"$varValue\" is too long for $varName. The maximum length is $length characters."
    } elseif { [dict exists $db $type] } {
	return [dict get $db $type]
    } else {
	return "\"$varValue\" is not a valid $type for $varName"
    }
}
