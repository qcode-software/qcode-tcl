package provide qcode 1.3
package require doc
namespace eval qc {
    namespace export qc *
}

proc qc::K {a b} {set a}

proc qc::try { try_code { catch_code ""} } {
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

doc try {
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
    foreach {varName defaultValue} $args {
	upvar 1 $varName value
	if { ![info exists value] || [string equal $value UNDEF] } {
	    set value $defaultValue
	} 
    }
}

doc default {
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
    upvar 1 $varName value
    if { ![info exists value] || [string equal $value $ifValue] } {
	set value $defaultValue
    } 
}

proc qc::sset { varName value } {
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

doc coalesce {
    Examples {
	% set foo 23
	% coalesce foo 13
	23
	% coalesce bar 13
	13
    }
}
	
proc qc::incr0 { varName amount } {
    upvar 1 $varName var
    if { [info exists var] } {
	set var [add $var $amount]
    } else {
	set var $amount
    }
    return $var
}

namespace import ::tcl::mathop::eq
namespace import ::tcl::mathop::ne

proc qc::call { proc_name args } {
    if { [info args $proc_name] eq "args" } {
	# Call the proc using a dict of corresponding local vars
	if { $args ne "" } {
	    return [uplevel 1 "$proc_name {*}\[dict_from $args\]"]
	} else {
	    return [uplevel 1 $proc_name]
	} 
    } else {
	# Call a proc using args of matching names to local variables.
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

proc qc::margin { cost price {dec_places 1} } {
    if { $price==0 } {
	return ""
    } else {
	return [round [expr {double($price-$cost)/$price*100}] $dec_places]
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
    return [string range $string 0 [expr {$length-1}]]
}

proc qc::truncate {string length} {
    if { [string length $string]<= $length } {
	return $string
    }
    set position [string wordstart $string $length]
    if { $position == 0 } {
	set position $length
    }
    return [string range $string 0 [expr {$position-1}]]
}

proc qc::iif { expr true false } {
    if { [uplevel 1 eval expr $expr] } {
	return $true
    } else {
	return $false
    }
}

proc qc::? { expr true false } {
    if { [uplevel 1 eval expr $expr] } {
	return $true
    } else {
	return $false
    }
}

proc qc::true { string {true true} {false false} } {
    if { [string is true -strict $string] } {
	return $true
    } else {
	return $false
    }
}

proc qc::false { string {true true} {false false} } {
    if { [string is false -strict $string] } {
	return $true
    } else {
	return $false
    }
}

proc qc::upper { string } {
    return [string toupper $string]
}

proc qc::lower { string } {
    return [string tolower $string]
}

proc qc::trim { string } {
    return [string trim $string]
}

proc qc::escapeHTML { html } {
    regsub -all {<} $html "\\&lt;" html
    regsub -all {>} $html "\\&gt;" html
    regsub -all {&} $html "\\&amp;" html
    regsub -all {\"} $html "\\&quot;" html
    return $html
}

proc qc::escapeHTML { html } {
    return [string map {< &lt; > &gt; & &amp; \" &quot; ' &\#39;} $html]
}

proc qc::unescapeHTML { text } {
    return [string map {&lt; < &gt; > &amp; & &\#39; ' &\#34; \" &quot; \"} $text]
}

proc qc::xsplit [list str [list regexp "\[\t \r\n\]+"]] {
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
    set mc \x00
    return [split [string map [list $splitString $mc] $string] $mc]
}

proc qc::perct {x n {p 1}} {
    return [round [expr {double($x)/$n*100}] $p]
}

# We'll begin with a box, and the plural is boxes;
# but the plural of ox became oxen not oxes.
# One fowl is a goose, but two are called geese,
# yet the plural of moose should never be meese.
# You may find a lone mouse or a nest full of mice;
# yet the plural of house is houses, not hice.
# If the plural of man is always called men,
# why shouldn't the plural of pan be called pen?
# If I spoke of my foot and show you my feet,
# and I give you a boot, would a pair be called beet?
# If one is a tooth and a whole set are teeth,
# why shouldn't the plural of booth be called beeth?
# Then one may be that, and three would be those,
# yet hat in the plural would never be hose,
# and the plural of cat is cats, not cose.
# We speak of a brother and also of brethren,
# but though we say mother, we never say methren.
# Then the masculine pronouns are he, his and him,
# but imagine the feminine, she, shis and shim.

proc qc::plural word {
    set exceptions {
	man men
	person people
	goose geese
	mouse mice
	nucleus nuclei
	syllabus syllabi
	focus foci
	fungus fungi
	cactus cacti
	phenomenon phenomena
	criterion criteria
	foot feet
        louse lice
	ox oxen
	tooth teeth
	genus genera
        phylum phyla
        radius radii
        cherub cherubim
        mythos mythoi
        formula formulae
	radio radios
	flex flexes
    }
    if { [dict exists $exceptions $word] } {
	return [dict get $exceptions $word]
    }

    if { [in {calf elf half hoof leaf loaf scarf self sheaf thief wolf} $word] } {
	return [string range $word 0 end-1]ves
    }
    if { [in {knife life wife} $word] } {
	return [string range $word 0 end-2]ves
    }
    if { [in {auto kangaroo kilo memo photo piano pimento pro solo soprano studio tattoo video zoo} $word] } {
	return ${word}s
    }
    # unchanged
    if { [in {cod deer fish perch sheep trout species barracks equipment conduit glasses} $word] } {
	return $word
    }

    switch -regexp -- $word {
	{ing$} - {ies$}           {return $word}
	{[ei]x$}                  {return [string range $word 0 end-2]ices}
	{[sc]h$} - {[soxz]$}      {return ${word}es}
	{[bcdfghjklmnprstvwxz]y$} {return [string range $word 0 end-1]ies}
	{child$}                  {return ${word}ren}
	{eau$}                    {return ${word}x}
	{is$}                     {return [string range $word 0 end-2]es}
	{woman$}                  {return [string range $word 0 end-2]en}

    }
    return ${word}s
}

proc qc::singular word {
    switch -- $word {
	men   {return man}
	feet  {return foot}
	geese {return goose}
	lice {return louse}
	mice {return mouse}
	oxen    {return ox}
	teeth {return tooth}
	calves - elves - halves - hooves - leaves - loaves - scarves
	- selves - sheaves - thieves - wolves
	{return [string range $word 0 end-3]f}
	knives - lives - wives
	{return [string range $word 0 end-3]fe}
	autos - kangaroos - kilos - memos
	- photos - pianos - pimentos - pros - solos - sopranos - studios
	- tattoos - videos - zoos
	{return [string range $word 0 end-1]}
	cod - deer - fish - offspring - perch - sheep - trout
	- species
	{return $word}
	genera {return genus}
	phyla {return phylum}
	radii {return radius}
	cherubim {return cherub}
	mythoi {return mythos}
	phenomena {return phenomenon}
	formulae {return formula}
	octopodes {return octopus}
	octopi {return octopus}
    }
    switch -regexp -- $word {
	{[ei]ices$}                  {return [string range $word 0 end-4]x}
	{[sc]hes$} - {[soxz]es$}      {return [string range $word 0 end-2]}
	{[bcdfghjklmnprstvwxz]ies$} {return [string range $word 0 end-3]y}
	{children$}                  {return [string range $word 0 end-3]}
	{eaux$}                    {return [string range $word 0 end-1]}
	{ises$}                     {return [string range $word 0 end-4]is}
	{women$}                  {return [string range $word 0 end-2]an}
	{s$}                       {return [string range $word 0 end-1]}
    }
    #Not handled
    error "Don't know singular for \"$word\""
}

proc qc::cmplen {string1 string2} {
    if { [string length $string1]<[string length $string2] } {
	return -1 
    } elseif {[string length $string1]==[string length $string2] } {
	return 0
    } else {
	return 1
    }
}

proc qc::subsets {l n} {
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
    # split a string into 2 parts at the delimiter
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
    # minimum non zero 
    set list {}
    foreach value $args {
	if { [string is double -strict $value] && $value>0 } {
	    lappend list $value
	}
    }
    return [min {*}$list]
}

proc qc::max_nz {args} {
    # max non zero price
    set list {}
    foreach value $args {
	if { [string is double -strict $value] && $value>0 } {
	    lappend list $value
	}
    }
    return [max {*}$list]
}

proc qc::md5 {string} {
    db_1row {select md5(:string) as md5}
    return $md5
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

proc qc::debug {message} {
    #| Write message to nsd log if Debugging is switched on.
    # Filter message by masking anything that looks like a card number.
    ns_log Debug [qc::format_cc_masked_string $message]
}

proc qc::log {args} {
    #| Write message to nsd log. If severity argument is not provided this defaults to "Notice". 
    # Valid severity values: Notice, Warning, Error, Fatal, Bug, Debug, Dev or an Integer value.
    # Filter Message by masking anything that looks like a card number before writing to log file.
    # Usage:
    # log Debug "Debug this"
    # log Notice "Notice this"
    # log "Notice this"

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

proc qc::exec_proxy {args} {
    if {[lindex $args 0] eq "-timeout"} {
	set timeout [lindex $args 1]
	set args [lrange $args 2 end]
    } else {
	set timeout 1000
    }
    if { ![catch {set handle [ns_proxy get exec]}] } {
	try {
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
