package provide qcode 1.5
package require doc
namespace eval qc {}

doc validate {
    Title "Checking User Input"
    Description {
	All user input should be checked to see that
	<ul>
	<li>It can be converted into a computer usable representation (cast).</li>
	<li>Conforms to a range of acceptable values or formats.</li>
	</ul>
	
	The <proc>check</proc> and <proc>checks</proc> procs provide a way of converting and checking data and then returning useful error messages.
	<p>
	Data is checked against a list of TYPEs.The empty string is always valid unless the type NOT NULL is specified.
	<p>
<table class="clsFlexGrid">
<colgroup>
<col name="Type">
<col name="Description">
<col name="Check with">
<col name="Cast with">
</colgroup>
<thead>
<tr>
<th>Type</th>
<th>Description</th>
<th>Check with</th>
<th>Cast with</th>
</tr>
</thead>
<tbody>
<tr>
<td>NOT NULL</td>
<td>not the empty string</td>
<td></td>
<td></td>
</tr>
<tr>
<td>INT</td>
<td>integer</td>
<td><a href="/doc/is_integer.html">is_integer</a></td>
<td><a href="/doc/cast_int.html">cast_int</a></td>
</tr>
<tr>
<td>DECIMAL</td>
<td>decimal number</td>
<td><a href="/doc/is_decimal.html">is_decimal</a></td>
<td><a href="/doc/cast_decimal.html">cast_decimal</a></td>
</tr>
<tr>
<td>POS</td>
<td>positive number</td>
<td><a href="/doc/is_pos.html">is_pos</a></td>
<td></td>
</tr>
<tr>
<td>NZ</td>
<td>non zero number</td>
<td><a href="/doc/is_non_zero.html">is_non_zero</a></td>
<td></td>
</tr>
<tr>
<td>PNZ</td>
<td>positive non zero number</td>
<td><a href="/doc/is_pnz.html">is_pnz</a></td>
<td></td>
</tr>
<tr>
<td>DATE</td>
<td>A valid date</td>
<td><a href="/doc/is_date.html">is_date</a></td>
<td><a href="/doc/cast_date.html">cast_date</a></td>
</tr>
<tr>
<td>EMAIL</td>
<td>A valid email address</td>
<td><a href="/doc/is_email.html">is_email</a></td>
<td></td>
</tr>
<tr>
<td>POSTCODE</td>
<td>A UK postcode</td>
<td><a href="/doc/is_postcode.html">is_postcode</a></td>
<td><a href="/doc/cast_postcode.html">cast_postcode</a></td>
</tr>
<tr>
<td>CREDITCARD</td>
<td>A credit card number</td>
<td><a href="/doc/is_creditcard.html">is_creditcard</a></td>
<td><a href="/doc/cast_creditcard.html">cast_creditcard</a></td>
</tr>
</tbody>
</table>
<h3>Examples</h3>
<example>
	proc user_create {name email password dob} {
	    checks {
		name STRING50 NOT NULL "Please enter your name in 50 characters or fewer"
		email STRING100 EMAIL NOT NULL
		password STRING20 NOT NULL
		dob DATE
	    }
	    # name, email and password are all mandatory but dob is option and may be the empty string.
	    ...
	    ...
	}
</example>
    }
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
	} elseif {[info commands is_$type] ne ""} {
	    lappend TYPES $TYPE
	    set n [llength [info args is_$type]]
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
	if { [in {POS NZ} $TYPE] && ![is_decimal $varValue] } {
	    # Implied cast
	    try {set varValue [cast_decimal $varValue]}
	} elseif { [info commands cast_$type] ne "" } {
	    try {
		if { [info exists type_args($TYPE)] } {
		    set varValue [cast_$type $varValue {*}$type_args($TYPE)]
		} else {
		    set varValue [cast_$type $varValue]
		}
	    }
	}
	# Check
	if {!([info exists type_args($TYPE)] && [is_$type $varValue {*}$type_args($TYPE)])
	    && 
	    !(![info exists type_args($TYPE)] && [is_$type $varValue])} {
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
    if { !$allow_html && [regexp {<[^>]+>} $varValue] } {
	error "\"[html_escape $varValue]\" contains HTML which is not allowed for $varName" {} USER
    }

    # Check contains creditcard by default
    if { !$allow_creditcards && [contains_creditcard $varValue] } {
	error [expr {[info exists errorMessage] ? $errorMessage : "\"[html_escape $varValue]\" contains a creditcard number which is not allowed for $varName"}] {} USER
    }

    return true
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
	% check surname STRING 30
	%
	% check surname STRING 30 NOT NULL
	surname is empty
	%
	# String length for use with varchar(n) database columns
	# can be checked with STRING n
	% set name "James Donald Alexander MacKenzie"
	check name STRING 30
	"James Donald Alexander MacKenzie" is too long for name. The maximum length is 30 characters.
    }
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

