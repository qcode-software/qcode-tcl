package provide qcode 2.0
package require doc
namespace eval qc {}

proc qc::format_commify {number} {
    #| Commify number into groups of three 2314 -> 2,314
    while {[regsub {^([-+]?\d+)(\d\d\d)} $number {\1,\2} number]} {}
    return $number
}

doc qc::format_commify {
    Examples {
	% format_commify 2314
	2,314
	%
	% format_commify 865425833.2354
	865,425,833.2354
    }
}

proc qc::format_money { value } {
    return [format_commify [round $value 2]]
}

doc qc::format_money {
    Examples {
	% format_money 2314
	2,314.00
	%
	% format_money 865425833.2354
	865,425,833.24
    }
}

proc qc::format_dec { value dec_places } {
    #| Round and commify decimal
    #| 2314.235 -> 2,314.24
    return [format_commify [qc::round $value $dec_places]]
}

doc qc::format_dec {
    Examples {
	% format_dec 2314 3
	2,314.000
	%
	% format_dec 865425833.2354 3
	865,425,833.235
    }
}

proc qc::format_int {value} {
    # Round to integer and commify
    # 2314.235 -> 2,314
    return [format_commify [qc::round $value 0]]
}

doc qc::format_int {
    Examples {
	% format_int 2.69
	3
	%
	% format_int 865425833.2354
	865,425,833
    }
}

proc qc::format_linebreak {string width} {
    #| Split $string into a list of lines without exceeding $width
    #| Avoid splitting words
    set result {}
    while {[string length $string]>$width} {
	set position [string last " " $string $width]
	if { $position <=0 } {
	    set position $width
	    lappend result [string range $string 0 [expr {$position-1}]]
	    set string [string range $string $position end]
	} else {
	    lappend result [string range $string 0 [expr {$position-1}]]
	    set string [string range $string [expr {$position+1}] end]
	}
      
    }
    lappend result $string
}

doc qc::format_linebreak {
    Examples {
	% set string {Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.}
	% 
	% format_linebreak $string 80
	{Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor } {incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis } {nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. } {Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu } {fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in } {culpa qui officia deserunt mollit anim id est laborum.}
	%
	%  join [format_linebreak $string 80] \n
	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
	incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis 
	nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
	Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu 
	fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in 
	culpa qui officia deserunt mollit anim id est laborum.
	%
    }
}

proc qc::format_cc {cc_no} {
    #| Format a credit card number in groups of 4 digits
    #| strip non digits
    regsub -all {[^0-9]} $cc_no {} cc_no
    return [join [format_linebreak $cc_no 4] " "]
}

doc qc::format_cc {
    Examples {
	% format_cc 4111111111111111
	4111 1111 1111 1111
	% format_cc "4111 1111 1111 1111"
	4111 1111 1111 1111
    }
}

proc qc::format_cc_bin {cc_no {prefix 6}} {
    #| First prefix digits of cc_no
    if { $prefix > 6 } { error "prefix must be less than 6" }
    
    regsub -all {[^0-9\*]} $cc_no {} cc_no
    return [string range $cc_no 0 "$prefix-1"]
}

doc qc::format_cc_bin {
    Examples {
	% format_cc_bin 4111111111111111
	411111
	% format_cc_bin "4111 **** **** 1111" 4
	4111
    }
}

proc qc::format_cc_tail {cc_no {suffix 4}} {
    #| First prefix digits of cc_no
    if { $suffix > 4 } { error "suffix must be less than 4" }
    
    regsub -all {[^0-9\*]} $cc_no {} cc_no
    return [string range $cc_no "end-[expr {$suffix - 1}]" end]
}

doc qc::format_cc_tail {
    Examples {
	% format_cc_tail 4111111111111111
	1111
	% format_cc_tail "4111 **** **** 1111" 4
	1111
    }
}

proc qc::format_cc_masked {cc_no {prefix 6} {suffix 4}} {
    if { ![is_creditcard $cc_no] } {
	error "Can't mask \"$cc_no\" because its is not a credit card number."
    }
    if { $prefix > 6 } { error "prefix must be less than 6" }
    if { $suffix > 4 } { error "suffix must be less than 4" }

    regsub -all {[^0-9]} $cc_no {} cc_no
    set masked_cc_no [string range $cc_no 0 [expr {$prefix - 1}]]
    append masked_cc_no [string repeat * [expr {[string length $cc_no] - $prefix - $suffix}]]
    append masked_cc_no [string range $cc_no end-[expr {$suffix - 1}] end] 

    return [join [format_linebreak $masked_cc_no 4] " "]
}

doc qc::format_cc_masked {
    Examples {
	% format_cc_masked 4111111111111111
	4111 11** **** 1111
	% format_cc_masked "4111 1111 1111 1111" 4 4
	4111 **** **** 1111
    }
}

proc qc::format_cc_masked_string {string {prefix 6} {suffix 4}} {
    if { $prefix > 6 } { error "prefix must be less than 6" }
    if { $suffix > 4 } { error "suffix must be less than 4" }
    
    set cc_no_pattern {(?:^|[^0-9]\.|[^\.\+0-9])([3456](?:\d[ \-\.]*){11,17}\d)(?:[^0-9]|$)}
    set indices [regexp -inline -indices -all -nocase $cc_no_pattern $string]
    set start 0
    set masked_string ""
   
    foreach {. item} $indices {
	set cc_no_str [string range $string [lindex $item 0] [lindex $item 1]]
	set cc_no [string map {" " "" - "" . ""} $cc_no_str]

	if { [is_creditcard $cc_no] } {
	    append masked_string [string range $string $start [lindex $item 0]-1]
	    
	    set masked_cc_no [string range $cc_no 0 [expr {$prefix - 1}]]
	    append masked_cc_no [string repeat * [expr {[string length $cc_no] - $prefix - $suffix}]]
	    append masked_cc_no [string range $cc_no end-[expr {$suffix - 1}] end] 

	    append masked_string [join [format_linebreak $masked_cc_no 4] " "]
	    set start [lindex $item 1]+1
	}
    }    
    append masked_string [string range $string $start end]
    
    return $masked_string
}

doc qc::format_cc_masked_string {
    Examples {
	% format_cc_masked_string 4111111111111111 6 4
	4111 11** **** 1111
	% format_cc_masked_string "Any old 4111 1111 1111 1111 or other 5555555555554444" 4 4
	Any old 4111 **** **** 1111 or other 5555 **** **** 4444
    }
}

proc qc::format_ordinal {number} {
    #| Format number with suffix 23 -> 23rd or 4 -> 4th
    # Taken from TCL Wiki RS
    set suffix th
    if {($number%100)<10 || ($number%100)>20} {
	switch -- [expr abs($number)%10] {
	    1 {set suffix st}
	    2 {set suffix nd}
	    3 {set suffix rd}
	}
    }
    append number $suffix
}

doc qc::format_ordinal {
    Examples {
	% format_ordinal 23
	23rd
	% format_ordinal 4
	4th
    }
}

# TODO Could this be named differently? Not sure a user would expect this to truncate
# strings longer than $width
proc qc::format_right0 {string width} {
    #| Right justified padded with leading 0's
    return [format "%0${width}.${width}s" $string]
}

doc qc::format_right0 {
    Examples {
	% format_right0 675 6
	000675
    }
}

proc qc::format_left {string width} {
    #| Padd with spaces left justified
    return [format "%-${width}.${width}s" $string]
}

doc qc::format_left {
    Examples {
	% puts ">>[format_left Dunstable 10]<<"
	>>Dunstable <<
	% format_left Dunstable 6
	Dunsta
    }
}

proc qc::format_right {string width} {
    # Pad with spaces right justified
    return [format "%${width}.${width}s" $string]
}

doc qc::format_right {
    Examples {
	% puts ">>[format_right Dunstable 10]<<"
	>> Dunstable<<
	% format_right Dunstable 6
	Dunsta
    }
}

proc qc::format_center { string width } {
    #| Pad string with spaces to be aligned centrally
    if { [string length $string]<$width } {
	append string [string repeat " " [expr {($width - [string length $string])/2}]]
    }
    return [format "%${width}.${width}s" $string]
}

proc qc::format_bool { value {true Yes} {false No}} {
    #| Cast boolean and wrap in span tags with style
    if { [string is true -strict $value] } {
	return "<span class=\"true\">$true</span>"
    } else {
	return "<span class=\"false\">$false</span>"
    }
}

doc qc::format_bool {
    Examples {
	% format_bool Y 
	<span class="true">Yes</span>
	%
	% format_bool No Aye Nay
	<span class="false">Nay</span>
    }
}

proc qc::format_yesno { value } {
    #| Call format_bool with default Yes/No
    return [format_bool $value Yes No]
}

proc qc::format_number {args} {
    #| format a number
    args $args -dp ? -sigfigs ? -commify yes -- value
    if { [info exists sigfigs] } {
	set value [sigfigs $value $sigfigs]
    }
    if { [info exists dp] } {
	set value [round $value $dp]
    }
    if { [true $commify] } {
	set value [format_commify $value]
    } 
    return $value
}

proc qc::format_if_number {args} {
    #| If value is a number then commify
    args $args -dp ? -sigfigs ? -zeros yes -commify yes -- value
    if { [is_decimal $value] } {
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
    }
    return $value
}

doc qc::format_if_number {
    Examples {
	% format_if_number 65242
	65,242
	% format_if_number Total
	Total
    }
}
