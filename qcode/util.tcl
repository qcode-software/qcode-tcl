package provide qcode 2.0
package require doc
namespace eval qc {
    namespace export qc *
}

# Tcl 8.5 only
namespace import ::tcl::mathop::eq
namespace import ::tcl::mathop::ne

proc qc::K {a b} {set a}

proc qc::try { try_code { catch_code ""} } {
    #| Try to execute the code try_code and catch any error. 
    #| If an error occurs then run catch_code.
    global errorMessage errorCode errorInfo
    switch -- [ catch { uplevel 1 $try_code } result ] {
        0 {
	    # Normal completion 
	}
        2 { 
	    return -code return $result 
	    # return from procedure 
	}
	3 {
	    return -code break
	    # break out of loop 
	}
	4 {
	    return -code continue
	    # continue loop 
	}
	default {
            set errorMessage $result
	    switch -- [ catch { uplevel 1 $catch_code } catch_result ] {
		0 {
		    # Normal completion 
		}
		2 { 
		    return -code return $catch_result 
		    # return from procedure 
		}
		3 {
		    return -code break
		    # break out of loop 
		}
		4 {
		    return -code continue
		    # continue loop 
		}
		default {
		    # Error in catch
		    return -code error -errorcode $errorCode $catch_result
		}
	    }
	}
    }
}

doc qc::try {
    Usage {try try_code ?catch_code?}
    Description {
	Try to execute the code <code>try_code</code> and catch any error. If an error occurs then run <code>catch_code</code>.
	<p>
	The global variables errorCode,errorInfo and errorMessage store info about the error.<br>
	[html_a errorCode {http://www.tcl.tk/man/tcl8.4/TclCmd/tclvars.htm\#M18}] - may also be user defined <br>
	[html_a errorInfo {http://www.tcl.tk/man/tcl8.4/TclCmd/tclvars.htm\#M25}] - TCL stack trace.<br>
	errorMessage - the result of executing the <code>try_code</code>
	The global errorMessage stores the result of exectuting the <code>try_code</code>.
    }
    Examples {
	% try {
	    expr 3/0
	} {
	    global errorMessage errorInfo
	    puts "An error was caught here."
	    puts "The error message was \"$errorMessage\" with errorCode \"$errorCode\""
	    puts "The stack trace was \n$errorInfo"
	}

	An error was caught here.
	The error message was "divide by zero" with errorCode "ARITH DIVZERO {divide by zero}"
	The stack trace was
	divide by zero
	    while executing
	"expr 3/0"
	    ("uplevel" body line 2)
	    invoked from within
	"uplevel 1 $try_code "

	
    }
}

proc qc::default { args } {
    #| If a variable does not exists then set its value to defaultValue
    foreach {varName defaultValue} $args {
	upvar 1 $varName value
	if { ![info exists value] || [string equal $value UNDEF] } {
	    set value $defaultValue
	} 
    }
}

doc qc::default {
    Usage {default varName defaultValue ?varName defaultValue? ...}
    Description {
	If a variable does not exists then set its value to <i>defaultValue</i>
    }
    Examples {
	% set foo 1
	% default foo 2
	1
	# foo is unaffected
	% 
	% default bar Yes
	Yes
	% set bar
	Yes
    }
}

proc qc::setif { varName ifValue defaultValue } {
    #| Set varName to be defaultValue if varName is set to ifValue or does not exist
    upvar 1 $varName value
    if { ![info exists value] || [string equal $value $ifValue] } {
	set value $defaultValue
    } 
}

doc qc::setif {
    Usage {
        qc::setif varName ifValue defaultValue
    }
    Description {
        Set varName to be defaultValue if varName is set to ifValue or does not exist
    }
    Examples {
        % set background-color
        NULL
        % qc::setif background-color NULL white
        white
        % set background-color
        white
        % set background-color red
        red
        % qc::setif background-color NULL white
        %
        % set background-color
        red
    }
}

proc qc::sset { varName value } {
    #| Set varName to value after having performed a subst.
    # strip leading newline
    regsub -all {^\n +} $value {} value
    # strip trailing newline
    regsub -all {\n$} $value {} value
    # strip leading whitespace
    regsub -all {\n[ \t]+} $value {\n} value
    # subst in uplevel namespace
    uplevel "set $varName \[[list subst $value]\]"
}

doc qc::sset {
    Description {
        Set varName to value after having performed a <code>subst</code>.
    }
    Usage {
        qc::sset varName value
    }
    Examples {
        % set album "Brighten The Corners"
        Brighten The Corners
        % set band "Pavement"
        Pavement
        % qc::sset xml {
	        <discography-entry>
		        [qc::xml band $band]
		        [qc::xml album $album]
	        </discography-entry>
        }
    
        <discography-entry>
        <band>Pavement</band>
        <album>Brighten The Corners</album>
        </discography-entry>
    }
}

proc qc::sappend { varName value } {
    #| Append value to the contents of varName having first performed a subst

    # strip leading newline
    regsub -all {^\n +} $value {} value
    # strip trailing newline
    regsub -all {\n$} $value {} value
    # strip leading whitespace
    regsub -all {\n[ \t]+} $value {\n} value
    # subst in uplevel namespace
    uplevel "append $varName \[[list subst $value]\]"
}

doc qc::sappend {
    Description {
        Append value to the contents of varName having first performed a <code>subst</code>.
    }
    Usage {
        qc::sappend varName value
    }
    Examples {
        % set album "Welcome to Mali"
        Welcome to Mali
        % set band "Amadou & Mariam"
        Amadou & Mariam
        % qc::sappend xml {
	        <discography-item>
		        [qc::xml band $band]
		        [qc::xml album $album]
	        </discography-item>
        }
    
        <discography-item>
        <band>Pavement</band>
        <album>Brighten The Corners</album>
        </discography-item>
        <discography-item>
        <band>Amadou &amp; Mariam</band>
        <album>Welcome to Mali</album>
        </discography-item>
    }
}

proc qc::coalesce { varName altValue } {
    #| If varName exists then return its value
    #| else return the altvalue
    upvar 1 $varName value
    if { [ info exists value] } {
	return $value
    } else {
	return $altValue
    }
}

doc qc::coalesce {
    Examples {
	% set foo 23
	% coalesce foo 13
	23
	% coalesce bar 13
	13
    }
}
	
proc qc::incr0 { varName amount } {
    #| Increment the value of varName by amount
    upvar 1 $varName var
    if { [info exists var] } {
	set var [add $var $amount]
    } else {
	set var $amount
    }
    return $var
}

doc qc::incr0 {
    Description {
        Increment the value of varName by $amount.
    }
    Usage {
        qc::incr0 varName amount
    }
    Examples {
        % set total
        can't read "total": no such variable
        % qc::incr0 total 100
        100
        % set total
        100
        % qc::incr0 total 50
        150
    }
}

proc qc::call { proc_name args } {
    #| Calls a procedure using local variables as arguments.
    #| Useful when a large number of arguments are required.
    if { [info args $proc_name] eq "args" } {
	# Call the proc using a dict of corresponding local vars
	if { $args ne "" } {
	    return [uplevel 1 "$proc_name {*}\[dict_from {*}$args\]"]
	} else {
	    return [uplevel 1 $proc_name]
	} 
    } else {
	# Call a proc using args of matching names to local variables.
        set largs {}
	foreach arg [info args $proc_name] {
	    upvar 1 $arg temp
	    if { [info default $proc_name $arg default_value] && ![info exists temp]} {
		# No corresponding variable exists 
		lappend largs $default_value
	    } elseif { [info exists temp] } {
		lappend largs $temp
	    } else {
		error "Cannot use variable \"$arg\" to call proc qc::\"$proc_name\":no such variable \"$arg\""
	    }
	}
	return [uplevel 1 $proc_name $largs]
    }
}

doc qc::call {
    Description {
        Calls a procedure using local variables as arguments.
    }
    Usage {
        qc::call proc_name args
    }
    Examples {
        % proc employee_record_hash { firstname middlename surname employee_id start_date dept branch } { 
            package require md5
            return [::md5::md5 -hex [list $firstname $middlename $surname $employee_id $start_date $dept $branch]]
        }
        % qc::call employee_record_hash
        Cannot use variable "firstname" to call proc qc::"employee_record_hash":no such variable "firstname"
        % set firstname "Angus"
        Angus
        % set middlename "Jamison"
        Jamison
        % set surname "Mackay"
        Mackay
        % set employee_id 999
        999
        % set start_date "2012-06-01"
        2012-06-01
        % set dept "Accounts"
        Accounts
        % set branch "Edinburgh"
        Edinburgh
        % set employee_hash [qc::call employee_record_hash]
        51A01DE13B5C7B5863743A3E5485237D
    }
}

proc qc::margin { cost price {dec_places 1} } {
    #| Calculates the gross margin on supplied cost and revenue
    if { $price==0 } {
	return ""
    } else {
	return [round [expr {double($price-$cost)/$price*100}] $dec_places]
    }
}

doc qc::margin {
    Description {
        Calculates the gross margin on supplied cost and revenue
    }
    Usage {
        qc::margin cost price ?dec_places?
    }
    Examples {
        % qc::margin 0.40 2.99
        86.6
        % qc::margin 0.40 2.99 3
        86.622
        % qc::margin 0.40 0.40
        0.0
    }
}

proc qc::breakpoint {{s {}}} {
    # From tcl cookbook
    if {![info exists ::bp_skip]} {
	set ::bp_skip [list]
    } elseif {[lsearch -exact $::bp_skip $s]>=0} {
	return
    }
    set who [info level -1]
    while 1 {
	# Display prompt and read command.
	puts -nonewline "$who/$s> "; flush stdout
	gets stdin line

	# Handle shorthands
	if {$line=="c"} {puts "continuing.."; break}
	if {$line=="i"} {set line "info locals"}

	# Handle everything else.
	catch {uplevel 1 $line} res
	puts $res
    }
}

proc qc::trunc {string length} {
    #| Truncates string to specified length
    return [string range $string 0 [expr {$length-1}]]
}

doc qc::trunc {
    Description {
        Truncates string to specified length
    }
    Usage {
        qc::trunc string length
    }
    Examples {
        % set string "This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately."
        This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.
        % set string_varchar50 [qc::trunc $string 50]
        This is a longer string than would be allowed in v
    }
}

proc qc::iif { expr true false } {
    #| Inline if statement
    if { [uplevel 1 eval expr $expr] } {
	return $true
    } else {
	return $false
    }
}

doc qc::iif {
    Description {
        Inline if statement which returns the appropriate value depending on the boolean expr
    }
    Usage {
        qc::iif expr true_value false_value
    }
    Examples {
        % proc xmas_sleeps { date } {
        set days [qc::date_days $date "2012-12-25"]
        return "There [qc::iif {$days==1} "is $days sleep" "are $days sleeps"] before xmas"
        }
        % xmas_sleeps 2012-08-21
        There are 126 sleeps before xmas
        % xmas_sleeps 2012-12-24
        There is 1 sleep before xmas
    }
}

proc qc::? { expr true false } {
    #| Shorthand version of qc::iif
    if { [uplevel 1 eval expr $expr] } {
	return $true
    } else {
	return $false
    }
}

proc qc::true { string {true true} {false false} } {
    #| Test if string is true. Recognised forms are "yes/no" "true/false" or 1/0.
    #| Optionally set the values to return for each case.
    if { [string is true -strict $string] } {
	return $true
    } else {
	return $false
    }
}

doc qc::true {
    Description {
        Test if string is true. Recognised forms are "yes/no" "true/false" or 1/0.
        Optionally set the values to return for each case.
    }
    Usage {
        qc::true string ?true_return_value? ?false_return_value?
    }
    Examples {
        % qc::true 1
        true
        % qc::true no
        false
        % qc::true true yes no
        yes
    }
}


proc qc::false { string {true true} {false false} } {
    #| Test if string is false. Recognised forms are "yes/no" "true/false" or 1/0.
    #| Optionally set the values to return for each case.
    if { [string is false -strict $string] } {
	return $true
    } else {
	return $false
    }
}

doc qc::false {
    Description {
        Test if string is false. Recognised forms are "yes/no" "true/false" or 1/0.
        Optionally set the values to return for each case.
    }
    Usage {
        qc::false string ?true_return_value? ?false_return_value?
    }
    Examples {
        % qc::false 1
        false
        % qc::false no
        true
        % qc::false true yes no
        no
    }
}

proc qc::escapeHTML { html } {
    #| TODO Deprecate for html_escape: Convert reserved HTML characters in a string into entities
    return [string map {< &lt; > &gt; & &amp; \" &quot; ' &\#39;} $html]
}

doc qc::escapeHTML {
    Description {
        Convert reserved HTML characters in a string into entities.
    }
    Usage {
        qc::escapeHTML html
    }
    Examples {
        % set text "This stuff is all true '1<2 & 3>2'." 
        This stuff is all true '1<2 & 3>2'.
        % set html "<html><p>[qc::escapeHTML $text]</p></html>"
        <html><p>This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.</p></html>
    }
}

proc qc::unescapeHTML { text } {
    #| Convert HTML entities back to their ascii characters
    return [string map {&lt; < &gt; > &amp; & &\#39; ' &\#34; \" &quot; \"} $text]
}

doc qc::unescapeHTML {
    Description {
        Convert HTML entities back to their ascii characters.
    }
    Usage {
        qc::unescapeHTML html
    }
    Examples {
        % set escaped_html "This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;."
        This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.
        % qc::unescapeHTML $escaped_html
        This stuff is all true '1<2 & 3>2'.
    }
}

proc qc::xsplit [list str [list regexp "\[\t \r\n\]+"]] {
    # TODO unused
    set list  {}
    while {[regexp -indices -- $regexp $str match submatch]} {
	lappend list [string range $str 0 [expr [lindex $match 0] -1]]
	if {[lindex $submatch 0]>=0} {
	    lappend list [string range $str [lindex $submatch 0]\
		    [lindex $submatch 1]] 
	}	
	set str [string range $str [expr [lindex $match 1]+1] end] 
    }
    lappend list $str
    return $list
}

proc qc::mcsplit {string splitString} {
    #| Split the string on the supplied string which can be of arbitrary length (unlike split).
    set mc \x00
    return [split [string map [list $splitString $mc] $string] $mc]
}

doc qc::mcsplit {
    Description {
        Split the string on the supplied string which can be of arbitrary length (unlike split).
    }
    Usage {
        qc::mcsplit sting splitString
    }
    Examples {
        % set test "this||is||a||delimited||string"
        this||is||a||delimited||string
        % split $test {||}
        this {} is {} a {} delimited {} string
        % qc::mcsplit $test {||}
        this is a delimited string
    }
}

proc qc::perct {x n {p 1}} {
    # TODO unused
    return [round [expr {double($x)/$n*100}] $p]
}


proc qc::subsets {l n} {
    #| Returns all possible subsets of length n from list l
    set subsets [list [list]]
    set result [list]
    foreach e $l {
	foreach subset $subsets {
	    lappend subset $e
	    if {[llength $subset] == $n} {
		lappend result $subset
	    } else {
		lappend subsets $subset
	    }
	}
    }
    return $result
}

doc qc::subsets {
    Description {
        Returns all possible subsets of length n from list l.
    }
    Usage {
        qc::subsets list length
    }
    Examples {
        % qc::subsets [list a b c d e f g h i] 9
        {a b c d e f g h i}
        % qc::subsets [list a b c d e f g h i] 8
        {a b c d e f g h} {a b c d e f g i} {a b c d e f h i} {a b c d e g h i} {a b c d f g h i} {a b c e f g h i} {a b d e f g h i} {a c d e f g h i} {b c d e f g h i}
    }
}

proc qc::permutations {list} {
    #| Returns all permuations of the supplied list
    set res [list [lrange $list 0 0]]
    set posL {0 1}
    foreach item [lreplace $list 0 0] {
	set nres {}
	foreach pos $posL {
	    foreach perm $res {
		lappend nres [linsert $perm $pos $item]
	    }
	}
	set res $nres
	lappend posL [llength $posL]
    }
    return $res
}

doc qc::permutations {
    Description {
        Returns all permuations of the supplied list
    }
    Usage {
        qc::permutations list 
    }
    Examples {
        % qc::permutations [list a b c]
        {c b a} {c a b} {b c a} {a c b} {b a c} {a b c}
        % qc::permutations [list a]
        a
    }
}

proc qc::split_pair {string delimiter} {
    #| split a string into 2 parts at the first occurence of the delimiter
    set list {}
    if {[set index [string first $delimiter $string]]!=-1} {
	lappend list [string trim [string range $string 0 [expr {$index-1}]]] 
	lappend list [string trim [string range $string [expr {$index+[string length $delimiter]}] end]]
    } else {
	error "Delimiter \"$delimiter\" was not found in the string \"$string\""
    }
    return $list
}

doc qc::split_pair {
    Description {
        Split a string into 2 parts at the first occurence of the delimiter
    }
    Usage {
        qc::split_pair string delimiter 
    }
    Examples {
        % qc::split_pair "key=key_value" =
        key key_value
    }
}

proc qc::min_nz {args} {
    # TODO Unused
    #| Return the minimum supplied value which is non zero 
    set list {}
    foreach value $args {
	if { [string is double -strict $value] && $value>0 } {
	    lappend list $value
	}
    }
    if { [llength $list] > 0 } {
        return [min {*}$list]
    } else {
        return ""
    }
}

doc qc::min_nz {
    Description {
        Return the minimum supplied value which is non zero 
    }
    Usage {
        qc::min_nz val1 ?val2? ?val3? ...
    }
    Examples {
        % qc::min_nz 0 1 5 7 3
        1
    }
}

proc qc::max_nz {args} {
    #| Return the maximum supplied value which is non zero 
    set list {}
    foreach value $args {
	if { [string is double -strict $value] && $value>0 } {
	    lappend list $value
	}
    }
    if { [llength $list] > 0 } {
        return [max {*}$list]
    } else {
        return ""
    }
}

doc qc::max_nz {
    Description {
        Return the maximum supplied value which is non zero 
    }
    Usage {
        qc::max_nz val1 ?val2? ?val3? ...
    }
    Examples {
        % qc::max_nz 0 1 5 7 3
        7
        % qc::max_nz 0 0 0 0 0
        % 
    }
}

package require md5
proc qc::md5 {string} {
    #| Returns the md5 hash of supplied string.
    return [string tolower [md5::md5 -hex $string]]
}

doc qc::md5 {
    Description {
        Returns the md5 hash of supplied string.
    }
    Usage {
        qc::md5 string
    }
    Examples {
        1> qc::md5 {This string requires hashing}
        fed9e24fe3df8ca8c093fca78e546ddc
    }
}

package require sha1
proc qc::sha1 {string} {
    # Return the sha1 hash
    return [sha1::sha1 $string]
}

proc qc::key_gen { args } {
    args $args -lower -upper -int -- length

    set alphabet_lower [list a b c d e f g h i j k l m n o p q r s t u v w x y z]
    set alphabet_upper [list A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
    set alphabet_int [list 0 1 2 3 4 5 6 7 8 9]

    if { [info exists lower] } {
	lappend alphabet {*}$alphabet_lower
    }
    if { [info exists upper] } {
	lappend alphabet {*}$alphabet_upper
    }
    if { [info exists int] } {
	lappend alphabet {*}$alphabet_int
    }
    default alphabet [concat $alphabet_lower $alphabet_upper $alphabet_int]

    set key ""
    while { [string length $key] < $length } {
	append key [lindex $alphabet [expr int(rand()*[llength $alphabet]) ]]
    } 

    return $key
}

proc qc::.. {from to {step 1} {limit ""}} {
    #| List all values from $from to $to. Will attempt to guess the input type.
    set result {}
    # Check month lists
    set lists {}
    lappend lists {January February March April May June July August September October November December}
    lappend lists {Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
    lappend lists {Mon Tue Wed Thu Fri Sat Sun}
    lappend lists {Monday Tuesday Wednesday Thursday Friday Saturday Sunday}
    foreach list $lists {
	lappend lists [upper $list] [lower $list]
    }
    foreach list $lists {
	if { [in $list $from] && [in $list $to] } {
	    set index [lsearch $list $from]
	    while { ($limit eq "" && [lindex $list $index] ne $to && [llength $result]<[llength $list]) \
			|| ([llength $result]<$limit)} {
		lappend result [lindex $list $index]
		set index [expr {($index+$step)%[llength $list]}]
	    }
	    if { $limit eq "" && [lindex $list $index] eq $to} {
		lappend result $to
	    }
	    return $result
	}
    }
    # Dates
    if { [is_date $from] && [is_date $to] } {
	if {![regexp {(-)?([0-9]+) (day|month|year)s?} $step -> sign scaler unit] } {
	    # default step 1 day
	    set sign +;set scaler 1; set unit day
	}
	for {set i $from} {([ne $sign -] && [date_compare $i $to]<=0) || ([eq $sign -] && [date_compare $i $to]>=0)} {set i [cast_date "$i $sign $scaler $unit"]} {
	    lappend result $i
	}
	return $result
    }
    # Expression
    set from [eval expr $from]
    set to [eval expr $to]
    if { [is_decimal $from] && [is_decimal $to] && [is_decimal $step]} {
	for {set i $from} {($step>0 && $i<=$to) || ($step<0 && $i>=$to)} {set i [expr {$i+$step}]} {
	    lappend result $i
	}
	return $result
    }
}

doc qc::.. {
    Description {
        List all values from $from to $to. Will attempt to guess the input type.
        The limit argument only affects alphabetic lists eg. Mon-Fri Jan-Feb
    }
    Usage {
        qc::.. from to ?step? ?limit?
    }
    Examples {
        % qc::.. 1 10
        1 2 3 4 5 6 7 8 9 10
        % qc::.. 1 10 2
        1 3 5 7 9
        % qc::.. Mon Fri
        Mon Tue Wed Thu Fri
        % qc::.. MON FRI
        MON TUE WED THU FRI
        % qc::.. jan dec 1 6
        jan feb mar apr may jun
        % qc::.. 2012-06-04 2012-07-01
        2012-06-04 2012-06-05 2012-06-06 2012-06-07 2012-06-08 2012-06-09 2012-06-10 2012-06-11 2012-06-12 2012-06-13 2012-06-14 2012-06-15 2012-06-16 2012-06-17 2012-06-18 2012-06-19 2012-06-20 2012-06-21 2012-06-22 2012-06-23 2012-06-24 2012-06-25 2012-06-26 2012-06-27 2012-06-28 2012-06-29 2012-06-30 2012-07-01
    }
}

proc qc::debug {message} {
    #| Write message to nsd log if Debugging is switched on.
    #| Filter message by masking anything that looks like a card number.
    # TODO Aolserver only
    ns_log Debug [qc::format_cc_masked_string $message]
}

doc qc::debug {
    Description {
        Write message to nsd log if Debugging is switched on.
        Filter message by masking anything that looks like a card number.
    }
    Usage {
        qc::debug message
    }
    Examples {
        qc::debug "Something bad happened."
    }
}

proc qc::log {args} {
    #| Write message to nsd log. If severity argument is not provided this defaults to "Notice". 
    # Valid severity values: Notice, Warning, Error, Fatal, Bug, Debug, Dev or an Integer value.
    # Filter Message by masking anything that looks like a card number before writing to log file.
    # Usage:
    # TODO Aolserver only

    if { [llength $args]==1 } {
	set severity Notice
	set message [lindex $args 0]
    } elseif { [llength $args]==2 } {
	set severity [lindex $args 0]
	set message [lindex $args 1]
    } else {
	error "Invalid args: usage log ?severity? message"
    } 
    ns_log $severity [qc::format_cc_masked_string $message]
}

doc qc::log {
    Description {
        Write message to nsd log. If severity argument is not provided this defaults to "Notice". 
        Valid severity values: Notice, Warning, Error, Fatal, Bug, Debug, Dev or an Integer value.
        Filter Message by masking anything that looks like a card number before writing to log file.
    }
    Usage {
        qc::log ?severity? message
    }
    Examples {
        % qc::log Debug "Debug this"
        % qc::log Notice "Notice this"
        % qc::log "Notice this"
    }
}

proc qc::exec_proxy {args} {
    #| Execute the given command.
    #| If running on aolserver will use ns_proxy, otherwise the command is executed directly.
    if {[lindex $args 0] eq "-timeout"} {
	set timeout [lindex $args 1]
	set args [lrange $args 2 end]
    } else {
	set timeout 1000
    }
    if { [info commands ns_proxy] eq "ns_proxy" } {
	set handle [ns_proxy get exec]
	qc::try {
	    set result [ns_proxy eval $handle [list exec {*}$args] $timeout]
	    ns_proxy release $handle
	    return $result
	} {
	    ns_proxy release $handle
	    error $::errorMessage $::errorInfo $::errorCode
	}
    } else {
	# No ns_proxy
	exec {*}$args
    }
}

doc qc::exec_proxy {
    Description {
        Execute the supplied command.
        If running on aolserver will use ns_proxy, otherwise the command is executed directly.
        A timeout can be optionally supplied in milliseconds. 
        Note, timeout is ignored if not running via ns_proxy.
    }
    Usage {
        qc::exec_proxy ?-timeout ms? command ?arg? ?arg? ...
    }
    Examples {
        % qc::exec_proxy hostname
        myhostname
        1> qc::exec_proxy -timeout 1000 wget http://cdimage.debian.org/debian-cd/6.0.5/amd64/iso-cd/debian-6.0.5-amd64-CD-1.iso
        wait for proxy "exec-proxy-0" failed: timeout waiting for evaluation
    }
}

proc qc::info_proc { proc_name } {
    #| Return the Tcl source code definition of a Tcl proc.
    if { [eq [info procs $proc_name] ""] && [eq [info procs ::$proc_name] ""] } {
	error "The proc $proc_name does not exist"
    }
    set proc_name [namespace which $proc_name]
    set largs {}
    foreach arg [info args $proc_name] {
	if { [info default $proc_name $arg value] } {
	    lappend largs [list $arg $value]
	} else {
	    lappend largs $arg
	}
    }
    set body [info body $proc_name]
    
    return "proc [string trimleft $proc_name :] \{$largs\} \{$body\}"
}

doc qc::info_proc {
    Description {
        Return the Tcl source code definition of a Tcl proc.
    }
    Usage {
        qc::info_proc proc_name
    }
    Examples {
        % qc::info_proc trim
        proc qc::trim {string} {
            #| Removes and leading or trailing white space.
            return [string trim $string]
        }
    }
}   

proc qc::which {command} {
    #| Return path of unix command - cache result in nsv on AOLserver if present
    if { [info commands nsv_exists] eq "nsv_exists" } {
	if { ![nsv_exists which $command] } {
	    nsv_set which $command [exec_proxy which $command]
	}
	set which [nsv_get which $command]
    } else {
	set which [exec which $command]
    }
    return $which
}

doc qc::which {
    Description {
        Return path of unix command - cache result in nsv on AOLserver if present
    }
    Usage {
        qc::which command
    }
    Examples {
        % qc::which sftp
        /usr/bin/sftp
    }
}

proc qc::string2hex {string} {
    #| Convert string to hex
    binary scan [encoding convertto utf-8 $string] H* hex
    return [regsub -all (..) $hex {\\x\1}]    
}
doc qc::string2hex {
    Examples {
        % string2hex Hello[format %c 256]
        \x48\x65\x6c\x6c\x6f\xc4\x80
    }
}