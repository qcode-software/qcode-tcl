namespace eval qc {
    namespace export round round_up rshift10 intplaces add sum subtr mult divide exp2string base frombase mantissa_exponent sigfigs sigfigs_ceil

    # Import Math functions
    namespace import ::tcl::mathfunc::max
    namespace import ::tcl::mathfunc::min
}
package require math::decimal

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

proc qc::round_up { value trunc_places } {
    #| Round up to the nearest $trunc_places decimal places
    set value [expr {double(ceil($value*pow(10,$trunc_places)))/pow(10,$trunc_places)}]
    return [format "%.${trunc_places}f" $value]
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

proc qc::add { n1 n2 } {
    #| Adds 2 numbers using decimal arithmetic (::math::decimal).
    set n1 [::math::decimal::fromstr $n1]
    set n2 [::math::decimal::fromstr $n2]
    return [::math::decimal::tostr [::math::decimal::add $n1 $n2]]
}

proc qc::sum { sum args } {
    #| Returns the sum of list of number using decimal arithmetic (::math::decimal).
    set sum [::math::decimal::fromstr $sum]
    foreach arg $args {
	set sum [::math::decimal::add $sum [::math::decimal::fromstr $arg]]
    }
    return [::math::decimal::tostr $sum]
}

proc qc::subtr { n1 n2 } {
    #| Subtracts 2 numbers using decimal arithmetic (::math::decimal).
    set n1 [::math::decimal::fromstr $n1]
    set n2 [::math::decimal::fromstr $n2]
    return [::math::decimal::tostr [::math::decimal::subtract $n1 $n2]]
}

proc qc::mult { n1 n2 } {
    #| Multiplies 2 numbers using decimal arithmetic (::math::decimal).
    set n1 [::math::decimal::fromstr $n1]
    set n2 [::math::decimal::fromstr $n2]
    return [::math::decimal::tostr [::math::decimal::multiply $n1 $n2]]
}

proc qc::divide { n1 n2 } {
    #| Divides 2 numbers using decimal arithmetic (::math::decimal).
    if { $n2 == 0 } {
        error "divide by zero"
    }
    set n1 [::math::decimal::fromstr $n1]
    set n2 [::math::decimal::fromstr $n2]
    return [::math::decimal::tostr [::math::decimal::divide $n1 $n2]]
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
    set exp [qc::cast integer [string range $number [add $k 1] end]]
    lassign [intplaces $mantissa] int places
    set exp [expr {$exp - $places}]
    if { $exp > 0 } {
	return $sign[append int [string repeat 0 $exp]]
    } else {
	return $sign[rshift10 $int [mult -1 $exp]]
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

proc qc::mantissa_exponent {x} {
    #| Returns the mantissa and exponent which would be used to represent x
    if { $x==0 } { return [list 0 0] }
    set m $x;set e 0
    while { abs($m) >=10 } { incr e; set m [expr {double($m)/10}] }
    while { abs($m)<1.0 } { incr e -1; set m [expr {$m*10}] }
    return [list $m $e]
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

