package provide qcode 2.6.5
package require doc
namespace eval qc {
    namespace export round round_up rshift10 intplaces add sum subtr mult exp2string base frombase mantissa_exponent sigfigs sigfigs_ceil

    # Import Math functions
    namespace import ::tcl::mathfunc::max
    namespace import ::tcl::mathfunc::min
}

proc qc::round { value dec_places } {
    #| Perform rounding of $value to $dec_places places.
    #| Handles exponentials.
    #| Rounds up on 5
    #| e.g. 2.345 -> 2.35
    # TODO Susceptible to buffer overflow for large values
    
    if { [string first e $value]!=-1 || [string first E $value]!=-1 } {
	set value [exp2string $value]
    }
    set k [string first . $value]
    set l [string length $value]
    
    if { $k==-1 } {
	if { $dec_places == 0 } {
	    return $value
	} else {
	    return "$value.[string repeat 0 $dec_places]"
	}
    } 
    if { $l - $k -1 < $dec_places } {
	return "$value[string repeat 0 [expr {$dec_places-$l+$k+1}]]"
    }
    if { $l - $k -1 == $dec_places } {
	return $value
    }

    if { $value < 0 } {
	set int "[string range $value 1 [expr {$k-1}]][string range $value [expr {$k+1}] [expr {$k+1+$dec_places}]]"
    } else {
	set int "[string range $value 0 [expr {$k-1}]][string range $value [expr {$k+1}] [expr {$k+1+$dec_places}]]"
    }

    if { $int != 0 } {
	set int [string trimleft $int 0]
    }

    if { wide($int)%wide(10) >= wide(5) } {
	# round up
	set result [expr {wide($int)/wide(10) + wide(1)}]
    } else {
	set result [expr {wide($int)/wide(10)}]
    }
    if { $value < 0 } {
	return "-[rshift10 $result $dec_places]"
    } else {
	return [rshift10 $result $dec_places]
    }
}

doc qc::round {
    Description {
        Perform rounding of $value to $dec_places places.
        Handles exponentials.
        Rounds up on 5
        e.g. 2.345 -> 2.35
    }
    Usage {
        qc::round value dec_places
    }
    Examples {
        % qc::round 1.23456789e5 2
        123456.79
        % qc::round 6 10
        6.0000000000
        % qc::round 6.66 8
        6.66000000
        % qc::round 0008.2345 3
        8.235
    }
}

proc qc::round_up { value trunc_places } {
    #| Round up to the nearest $trunc_places decimal places
    set value [expr {double(ceil($value*pow(10,$trunc_places)))/pow(10,$trunc_places)}]
    return [format "%.${trunc_places}f" $value]
}

doc qc::round_up {
    Description {
        Round up to the nearest $trunc_places decimal places
    }
    Usage {
        qc::round_up value trunc_places
    }
    Examples {
        % qc::round_up 2.30 1
        2.3
        % qc::round_up 2.31 1
        2.4
        % qc::round_up 2.33333 2
        2.34
    }
}

proc qc::rshift10 {int dec_places} {
    #| Format right aligned padding left
    set s [string length $int]
    if { $int == 0 } {
	if { $dec_places > 0 } {
	    return "0.[string repeat 0 $dec_places]"
	} else {
	    return 0
	}
    }
    if { $dec_places == 0 } {
	return $int
    }
    if { $s < $dec_places } {
	return "0.[string repeat 0 [expr {$dec_places - $s}]]$int"
    }
    if { $s == $dec_places } {
	return "0.$int"
    }
    if { $s > $dec_places } {
	return "[string range $int 0 [expr {$s - $dec_places-1}]].[string range $int [expr {$s - $dec_places}] end]"
    }
}

doc qc::rshift10 {
    Description {
        Move decimal point $dec_places to the left 
    }
    Usage {
        qc::rshift10 int dec_places
    }
    Examples {
        % qc::rshift10 6 3
        0.006
        % qc::rshift10 23 1
        2.3
    }
}

proc qc::intplaces { number } {
    #| Shift the decimal point n places to the right until $number is an int. Return int and n.
    set k  [string first . $number]
    if { $k ==-1 } {
	set dec_places 0
    } else {
	set dec_places [expr {[string length $number] - $k - 1}]
	set number "[string range $number 0 [expr {$k-1}]][string range $number [expr {$k+1}] end]"
    }

    if { $number!=0 } {
	# Prevent octal interpretation
	set number [string trimleft $number 0]
    } else {
	set number 0
    }
    return [list $number $dec_places]
}

doc qc::intplaces {
    Description {
        Shift the decimal point n places to the right until $number is an int. Return int and n.
    }
    Usage {
        qc::intplaces number
    }
    Examples {
        % qc::intplaces 23.4
        234 1
        % qc::intplaces 0.235
        235 3
    }
}

proc qc::add { n1 n2 } {
    #| Adds 2 numbers with check for overflow
    return [expr {$n1 + $n2}]
}

doc qc::add {
    Description {
        Adds two numbers with check for overflow
    }
    Usage {
        qc::add n1 n2
    }
    Examples {
        % qc::add 2 2
        4
    }
}

proc qc::sum { sum args } {
    #| Returns the sum of list of number.
    foreach arg $args {
	set sum [add $sum $arg]
    }
    return $sum
}

doc qc::sum {
    Description {
        Returns the sum of list of numbers.
    }
    Usage {
        qc::sum n1 ?n2? ?n3? ....
    }
    Examples {
        % qc::sum 1
        1
        % qc::sum 1 1 1 1 1 1 1 1 
        8
    }
}

proc qc::subtr { n1 n2 } {
    #| Subtracts with check for overflow
    return [expr {$n1 - $n2}]
}

doc qc::subtr {
    Description {
        Subtracts with check for overflow
    }
    Usage {
        qc::subtr n1 n2
    }
    Examples {
        % qc::subtr 5 1
        4
        %  qc::subtr 1.11111 999999999
        -999999997.88889
    }
}

proc qc::mult { n1 n2 } {
    #| Multiplies 2 numbers with check for overflow
    return [expr {$n1*$n2}]
}

doc qc::mult {
    Description {
        Multiplies 2 numbers with check for overflow
    }
    Usage {
        qc::mult n1 n2
    }
    Examples {
        % qc::mult 2 6
        12
    }
}

proc qc::exp2string { number } {
    #| Convert floats including exponentials to strings
    set number [string tolower $number]
    set k  [string first e $number]
    if { $k == -1 } {
	return $number
    }
    if { [eq [string index $number 0] -] } {
	set mantissa [string range $number 1 [add $k -1]]
	set sign -
    } else {
	set mantissa [string range $number 0 [add $k -1]]
	set sign ""
    }
    set exp [string range $number [add $k 1] end]
    lassign [intplaces $mantissa] int places
    set exp [expr {$exp - $places}]
    if { $exp > 0 } {
	return $sign[append int [string repeat 0 $exp]]
    } else {
	return $sign[rshift10 $int [mult -1 $exp]]
    }
}

doc qc::exp2string {
    Description {
        Convert floats including exponentials to strings
    }
    Usage {
        qc::exp2string number 
    }
    Examples {
        % qc::exp2string -1.23e6
        -1230000
        % qc::exp2string 10000
        10000
    }
}

proc qc::base {base number} {
    #| Convert supplied number to specified base 
    set negative [regexp ^-(.+) $number -> number] ;# (1)
    set digits {0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N
        O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p
        q r s t u v w x y z}

    set res {}
    while {$number} {
        set digit [expr {$number % $base}]
        set res [lindex $digits $digit]$res
        set number [expr {$number / $base}]
    }
    if $negative {set res -$res}
    set res
 }

doc qc::base {
    Description {
        Convert supplied number to specified base 
    }
    Usage {
        qc::base base number
    }
    Examples {
        % qc::base 2 1024
        10000000000
        % qc::base 8 1024 
        2000
        % qc::base 16 15
        F
    }
}

proc qc::frombase {base number} {
    #| Converts a number from the specified base to base 10
    set digits {0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N
        O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p
        q r s t u v w x y z}
    set negative [regexp ^-(.+) $number -> number]
    set res 0
    foreach digit [split $number ""] {
        set decimalvalue [lsearch $digits $digit]
        if {$decimalvalue<0 || $decimalvalue >= $base} {
            error "bad digit $decimalvalue for base $base"
        }
        set res [expr {$res*$base + $decimalvalue}]
    }
    if $negative {set res -$res}
    set res
}

doc qc::frombase {
    Description {
        Converts a number from the specified base to base 10
    }
    Usage {
        qc::frombase base number
    }
    Examples {
        % qc::frombase 16 F
        15
        % qc::frombase 2 1001101
        77
        % qc::frombase 8 77
        63
    }
}

proc qc::mantissa_exponent {x} {
    #| Returns the mantissa and exponent which would be used to represent x
    if { $x==0 } { return [list 0 0] }
    set m $x;set e 0
    while { abs($m) >=10 } { incr e; set m [expr {double($m)/10}] }
    while { abs($m)<1.0 } { incr e -1; set m [expr {$m*10}] }
    return [list $m $e]
}

doc qc::mantissa_exponent {
    Description {
        Returns the mantissa and exponent which represent x
    }
    Usage {
        qc::mantissa_exponent x
    }
    Examples {
        % qc::mantissa_exponent -0.000015463
        -1.5463000000000002 -5
        % qc::mantissa_exponent 912000000
        9.120000000000001 8
    }
}

proc qc::sigfigs {x n} {
    #| Returns x to n significant figures
    if { $x==0 } { return 0 }
    lassign [qc::mantissa_exponent $x] m e
    set p [expr {pow(10,$e-$n+1)}]
    if { $n-$e-1>0 } {
	return [qc::round [expr {round(double($x)/$p)*$p}] [expr {$n-$e-1}]]
    } else {
	return [qc::round [expr {round(double($x)/$p)*$p}] 0]
    }
}

doc qc::sigfigs {
    Description {
        Returns x to n significant figures
    }
    Usage {
        qc::sigfigs x n
    }
    Examples {
        % qc::sigfigs 9192837465 2
        9200000000
        % qc::sigfigs 12 1
        10
        % qc::sigfigs 12 5
        12.000
        % qc::sigfigs 12.2222 3
        12.2
    }
}

proc qc::sigfigs_ceil {x n} {
    #| Returns x to n significant figures rounding up
    if { $x==0 } { return 0 }
    lassign [qc::mantissa_exponent $x] m e
    set p [expr {pow(10,$e-$n+1)}]
    if { $n-$e-1>0 } {
	return [qc::round [expr {ceil(double($x)/$p)*$p}] [expr {$n-$e-1}]]
    } else {
	return [qc::round [expr {ceil(double($x)/$p)*$p}] 0]
    }
}

doc qc::sigfigs_ceil {
    Description {
        Returns x to n significant figures rounding up
    }
    Usage {
        qc::sigfigs_ceil x n
    }
    Examples {
        % qc::sigfigs_ceil 9192837465 2
        9200000000
        % qc::sigfigs_ceil 12 1
        20
        % qc::sigfigs_ceil 12 5
        12.000
        % qc::sigfigs_ceil 12.2222 3
        12.3
    }
}
