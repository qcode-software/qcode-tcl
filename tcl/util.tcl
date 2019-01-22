namespace eval qc {
    # Tcl 8.5 only
    namespace import ::tcl::mathop::eq
    namespace import ::tcl::mathop::ne

    namespace export K default setif sset sappend coalesce incr0 call margin breakpoint trunc iif ? true false escapeHTML unescapeHTML xsplit mcsplit perct subsets permutations split_pair min_nz max_nz key_gen .. debug log exec_proxy info_proc which string2hex not_null eq ne commonmark2html
}

proc qc::K {a b} {set a}

proc qc::try { try_code { catch_code ""} } {
    #| Try to execute the code try_code and catch any error. 
    #| If an error occurs then run catch_code.
    set return_code [ catch { uplevel 1 $try_code } result options]
    switch $return_code {
        1 {
            # Error
            set return_code [ catch { uplevel 1 $catch_code } catch_result options]
            # Preserve TCL_RETURN
            if { $return_code == 2 && [dict get $options -code] == 0 } {
                dict set options -code return
            } else {
                # Return in parent stack frame instead of here
                dict incr options -level
            }
            return -options $options $catch_result
	}
        default {
            # ok, return, break, continue

            # Preserve TCL_RETURN
            if { $return_code == 2 && [dict get $options -code] == 0 } {
                dict set options -code return
            } else {
                # Return in parent stack frame instead of here
                dict incr options -level
            }
            return -options $options $result
        }
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

proc qc::setif { varName ifValue defaultValue } {
    #| Set varName to be defaultValue if varName is set to ifValue or does not exist
    upvar 1 $varName value
    if { ![info exists value] || [string equal $value $ifValue] } {
	set value $defaultValue
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

proc qc::call_with {proc_name args} {
    #| Calls proc_name by mapping name value pairs to named args.
    if { [llength $args]%2 != 0 } {
        return -code error "usage qc::call_with proc_name ?name value?"
    }
    
    set proc_args [info args $proc_name]
    set largs {}
    foreach arg $proc_args {
	if { [dict exists $args $arg] } {
            set value [dict get $args $arg]
            if {$arg eq "args"} {
                lappend largs {*}$value
            } else {
                lappend largs $value
            }
	} else {
            if { [info default $proc_name $arg default_value] } {
                lappend largs $default_value
            } else {
                return -code error "Missing argument: \"$arg\"."
            }
        }
    }
    return [uplevel 0 $proc_name $largs]    
}

proc qc::margin { cost price {dec_places 1} } {
    #| Calculates the gross margin on supplied cost and revenue
    if { $price==0 } {
	return ""
    } else {
	return [qc::round [expr {double($price-$cost)/$price*100}] $dec_places]
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

proc qc::iif { expr true false } {
    #| Inline if statement
    if { [uplevel 1 eval expr $expr] } {
	return $true
    } else {
	return $false
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

proc qc::false { string {true true} {false false} } {
    #| Test if string is false. Recognised forms are "yes/no" "true/false" or 1/0.
    #| Optionally set the values to return for each case.
    if { [string is false -strict $string] } {
	return $true
    } else {
	return $false
    }
}

proc qc::escapeHTML { html } {
    #| TODO Deprecate for html_escape: Convert reserved HTML characters in a string into entities
    return [string map {< &lt; > &gt; & &amp; \" &quot; ' &\#39;} $html]
}

proc qc::unescapeHTML { text } {
    #| Convert HTML entities back to their ascii characters
    return [string map {&lt; < &gt; > &amp; & &\#39; ' &\#34; \" &quot; \"} $text]
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

proc qc::perct {x n {p 1}} {
    # TODO unused
    return [qc::round [expr {double($x)/$n*100}] $p]
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

package require md5
proc qc::md5 {string} {
    #| Returns the md5 hash of supplied string.
    return [string tolower [::md5::md5 -hex $string]]
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
    if { [qc::is date $from] && [qc::is date $to] } {
	if {![regexp {(-)?([0-9]+) (day|month|year)s?} $step -> sign scaler unit] } {
	    # default step 1 day
	    set sign +;set scaler 1; set unit day
	}
	for {set i $from} {([ne $sign -] && [date_compare $i $to]<=0) || ([eq $sign -] && [date_compare $i $to]>=0)} {set i [cast date "$i $sign $scaler $unit"]} {
	    lappend result $i
	}
	return $result
    }
    # Expression
    set from [eval expr $from]
    set to [eval expr $to]
    if { [qc::is decimal $from] && [qc::is decimal $to] && [qc::is decimal $step]} {
	for {set i $from} {($step>0 && $i<=$to) || ($step<0 && $i>=$to)} {set i [expr {$i+$step}]} {
	    lappend result $i
	}
	return $result
    }
}

proc qc::debug {message} {
    #| If running in naviserver and debugging is switched on then write message to nsd log.
    #| Otherwise write message to stdout.
    #| Filter message by masking anything that looks like a card number.
    log Debug [qc::format_cc_masked_string $message]
}

proc qc::log {args} {
    #| If running in naviserver then write message to nsd log using App: prefix. 
    #| Otherwise write message to stout or stderr.
    #| Default severity argument to "Notice". 
    #| Filter message by masking anything that looks like a card number.
    #| Usage: qc::log ?Severity? message
    
    # Parse args
    set list [list Debug Notice Error]
    if { [llength $args]==1 } {
	set severity Notice
	set message [lindex $args 0]
    } elseif { [llength $args]==2 } {
	set severity [lindex $args 0]
        if { $severity ni $list } {
            error "Severity must be one of \"$list\""
        }
	set message [lindex $args 1]
    } else {
	error "Invalid args: usage log ?severity? message"
    }    
    
    # Mask anything in message that looks like a card number 
    set message [qc::format_cc_masked_string $message]

    # Output message
    if { [info commands ns_log] eq "ns_log" } {
        # Write to naviserver's nsd log
        if { "App:$severity" ni [ns_logctl severities] } {
            # turn on this log level.
            ns_logctl severity App:$severity on
        }
        ns_log "App:$severity" $message
    } elseif { $severity eq "Error" } {
        # Write to stderr
        puts stderr $message
    } else {
        # Write to stdout
        puts stdout  $message
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
	::try {
	    set result [ns_proxy eval $handle [list exec {*}$args] $timeout]
	    ns_proxy release $handle
	    return $result
	} on error {error_message options} {
	    ns_proxy release $handle
	    error $error_message [dict get $options -errorinfo] [dict get $options -errorcode]
	}
    } else {
	# No ns_proxy
	exec {*}$args
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

proc qc::string2hex {string} {
    #| Convert string to hex
    binary scan [encoding convertto utf-8 $string] H* hex
    return [regsub -all (..) $hex {\\x\1}]    
}

proc qc::not_null {var} {
    #| Test if this variable exists and is not the empty string
    upvar $var value
    return [expr {[info exists value] && $value ne "" }]
}

proc qc::commonmark2html {args} {
    #| Converts Commonmark Markdown (http://commonmark.org) to  HTML.
    qc::args $args -unsafe -- markdown
    set markdown [string map {\r ""} $markdown] ;#removes ^M (alternative carriage return) characters
    set html [exec cmark << $markdown]
    if {[info exists unsafe]} {
        return $html
    } elseif { [qc::is safe_html $html] } {
        return $html
    } else {
        return -code error -errorcode CAST "Markdown contains unsafe HTML."
    }
}

proc qc::glob_recursive {args} {
    #| Return names of files that match patterns, including files in sub-directories
    # Usage: same as glob (see http://www.tcl.tk/man/tcl8.5/TclCmd/glob.htm),
    # with additional max_depth switch
    qc::args $args -join -nocomplain -tails -path ? -directory ? -types ? -max_depth 10 -- args

    # Use a single glob call, but extend each pattern passed in with */ prefixes
    # (eg. *.html becomes *.html */*.html */*/*.html etc.)
    if { [info exists join] } {
        set base_patterns [list [join $args /]]
    } else {
        set base_patterns $args
    }
    set patterns $base_patterns
    foreach depth [.. 1 $max_depth] {
        foreach pattern $base_patterns {
            lappend patterns [join [list {*}[lrepeat $depth *] $pattern] /]
        }        
    }

    # Switches and options to be passed on to glob
    # switches
    set switches [list]
    foreach var {nocomplain tails} {
        if { [info exists $var] } {
            lappend switches -${var}
        }
    }
    # options
    set options [list]
    foreach var {path directory types} {
        if { [info exists $var] } {
            lappend options -${var} [set $var]
        }
    }

    # Call glob and return the results
    return [glob {*}$switches {*}$options -- {*}$patterns]
}

proc qc::args_qualified2unqualified {} {
    #| Creates an unqualified variable in the caller's stack frame for each qualified argument
    #| present in the caller but only if the resulting variable would be unambiguous.
    #| E.G. Caller's args: { table.foo }
    #|      -> Variable named "foo" is set in caller.
    #|      Caller's args: { table.foo other.foo }
    #|      -> No new variables set in caller because "foo" would be ambiguous.
    set caller_args [info args [dict get [info frame -1] proc]]
    foreach item [qc::args_unambiguous {*}$caller_args] {
        upvar 1 $item value
        qc::upset 1 [qc::arg_shortname $item] $value
    }
}

proc qc::arg_shortname {name} {
    #| Returns the shortname of a name if it is qualified otherwise returns the name.
    if { [regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
        return $column
    } else {
        return $name
    }
}

proc qc::args_unambiguous {args} {
    #| Returns items from the given list that would be unambiguous if shortnened by unqualifying them.
    #| E.G. unamibguous table.foo table.bar table.baz other.baz
    #|      -> table.foo table.bar
    set unambiguous {}
    set shortnames [map {x {qc::arg_shortname $x}} $args]
    foreach shortname $shortnames arg $args { 
        if { [llength [lsearch -all $shortnames $shortname]]==1 } {
            lappend unambiguous $arg
        }
    }
    return $unambiguous
}

proc qc::memoize {args} {
    #| Wrapper that caches the result of script evaluation to improve performance for future evaluations.
    #| Usage: `qc::memoize -timeout ? -expires ? script args`
    #| Example: `qc::memoize -expires 2520 -timeout 1 deep_tought "meaning of life"`
    # The script result remains valid until the supplied expire time passes, or forever if not specified. 
    # The value for -expires can be expressed either as an absolute time (large values intrepreted as seconds since epoch) 
    # or as an seconds offset from the current time.
    # If two threads execute the same script and args, one will wait for the other to compute the result and store it in the cache. 
    # The -timeout option specifies how long to wait in seconds.
    # nb. currently requires ns_memoize to perform memoization.
  
    if { [info commands ns_memoize] eq "ns_memoize" } {
        # ns_memoize available
        return [eval [list ns_memoize {*}$args]]
    } else {
        # ns_memoize is unavailable - evaluate script in the caller without memoization
        qc::args $args -expires ? -timeout ? -- args

        return [eval {*}$args]
    }
}

proc qc::postcode_parse { postcode } {
    #| Parse postcode into dict of constituent parts

    set postcode [string toupper $postcode]
    set area_regexp {[A-Z]{1,2}}
    set district_regexp {[0-9][0-9]?[A-Z]?}
    set space_regexp {\s}
    set sector_regexp {[0-9]}
    set unit_regexp {[A-Z]{2}}
    set parse_regexp "
        ^
        ( \$ | ${area_regexp} )
        ( \$ | ${district_regexp} )
        ( \$ | ${space_regexp} )
        ( \$ | ${sector_regexp} )
        ( \$ | ${unit_regexp} )
        $
    "
    # Parse postcode extracting area, district, sector and unit.
    if { ! [regexp -expanded $parse_regexp $postcode match area district space sector unit] } {
        error "Unable to parse postcode \"$postcode\""
    }
    return [qc::dict_from area district space sector unit]
}

proc qc::regexp_escape {string} {
    #| Escape string for use inside TCL regular expression
     set list {
	\\ \\\\ 
	^ \\^ 
	. \\. 
	\[ \\\[ 
	\] \\\] 
	\$ \\\$ 
	\( \\\( 
	\) \\\) 
	| \\| 
	* \\* 
	+ \\+ 
	? \\? 
	\{ \\\{
	\} \\\}
    } 

    return [string map $list $string]
}
