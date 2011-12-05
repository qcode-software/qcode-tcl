package provide qcode 1.2
package require doc
namespace eval qc {}
proc qc::round { value dec_places } {
    # round up on 5
    # e.g. 2.345 -> 2.35
    
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
    # e.g 2.30->2.3  2.31->2.4  2.39->2.4
    set value [expr {double(ceil($value*pow(10,$trunc_places)))/pow(10,$trunc_places)}]
    return [format "%.${trunc_places}f" $value]
}

proc qc::rshift10 {int dec_places} {
    # format right aligned padding left
    # eg 6 -> 0.006 for 3 dec_places 
    # or 
    # 23 ->2.3 for 1 dec_places 
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
    # return the number as an integer with the number of places shifted
    # eg 23.4 -> 234 and 1
    # eg 0.235 -> 235 and 3
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
    set result [expr {$n1 + $n2}]
    
    # Check for buffer overflow
    if { ($n1>0 && $n2>0 && $result<0) || ($n1<0 && $n2<0 && $result>0) } {
	error "Result is too large to represent"
    }

    return $result
}

proc qc::sum { sum args } {
    foreach arg $args {
	set sum [add $sum $arg]
    }
    return $sum
}

proc qc::subtr { n1 n2 } {
    set result [expr {$n1 - $n2}]
    
    # Check for buffer overflow
    if { ($n1<0 && $n2>0 && $result>0) || ($n1>0 && $n2<0 && $result<0) } {
	error "Result is too large to represent"
    }

    return $result
}

proc qc::mult { n1 n2 } {
    set result [expr {$n1*$n2}]

    # Check for buffer overflow
    if { !($n1<=32767 && $n1>=-32768 && $n2<=32767 && $n2>=-32768) 
	 && $n2!=0 
	 && ($result/$n2!=$n1 || ($n2==-1 && $n1<0 && $result < 0)) } {
	error "Result is too large to represent"
    }

    return $result
}

proc qc::bigadd { n1 n2 } {
    # Convert to integers
    lassign [intplaces $n1] n1 p1
    lassign [intplaces $n2] n2 p2

    # Line up
    if { $p1>$p2 } { 
	set p $p1
	append n2 [string repeat 0 [expr {$p1-$p2}]]
    } else { 
	set p $p2
	append n1 [string repeat 0 [expr {$p2-$p1}]]
    }

    set result [expr {wide($n1) + wide($n2)}]
    
    # Check for buffer overflow
    if { ($n1>0 && $n2>0 && $result<0) || ($n1<0 && $n2<0 && $result>0) } {
	error "Result is too large to represent"
    }

    # Format answer
    if { $p>0 } {
	return [rshift10 $result $p]
    } else {
	return $result
    }
}

proc qc::bigsubtr { n1 n2 } {
    # $n1 - $n2

    # Convert to integers
    lassign [intplaces $n1] n1 p1
    lassign [intplaces $n2] n2 p2

    # Line up
    if { $p1>$p2 } { 
	set p $p1
	append n2 [string repeat 0 [expr {$p1-$p2}]]
    } else { 
	set p $p2
	append n1 [string repeat 0 [expr {$p2-$p1}]]
    }

    set result [expr {wide($n1) - wide($n2)}]
    
    # Check for buffer overflow
    if { ($n1<0 && $n2>0 && $result>0) || ($n1>0 && $n2<0 && $result<0) } {
	error "Result is too large to represent"
    }

    # Format answer
    if { $p>0 } {
	return [rshift10 $result $p]
    } else {
	return $result
    }
}


proc qc::bigmult { n1 n2 } {
    # Convert to integers
    lassign [intplaces $n1] n1 p1
    lassign [intplaces $n2] n2 p2

    set result [expr {wide($n1)*wide($n2)}]

    # Check for buffer overflow
    if { !($n1<=32767 && $n1>=-32768 && $n2<=32767 && $n2>=-32768) 
	 && $n2!=0 
	 && ($result/$n2!=$n1 || ($n2==-1 && $n1<0 && $result < 0)) } {
	error "Result is too large to represent"
    }

    # format result
    set p [expr {$p1+$p2}]
    if { $p>0 } {
	return [rshift10 $result $p]
    } else {
	return $result
    }
}

proc qc::exp2string { number } {
    # Convert floats including exponentials to strings
    # eg -1.234e-3
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
    set exp [subtr $exp $places]
    if { $exp > 0 } {
	return $sign[append int [string repeat 0 $exp]]
    } else {
	return $sign[rshift10 $int [mult -1 $exp]]
    }
}

proc qc::base {base number} {
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

proc qc::min {args} {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    return [lindex [lsort -real $args] 0]
}

proc qc::max {args} {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    return [lindex [lsort -real -decreasing $args] 0]
}

proc qc::min2 {args} {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    if { [eq [lindex $args 0] -integer] } { 
	set type integer
	ldelete args 0
    } elseif { [eq [lindex $args 0] -real] } {
	set type real
	ldelete args 0
    } else {
	set type ascii
	foreach value $args {
	    if {[is_integer $value] && [ne $type real]} {
		set type integer
	    } elseif { [is_decimal $value] } {
		set type real
	    } else {
		set type ascii 
		break
	    }
	}
    }
    return [lindex [lsort -$type $args] 0]
}

proc qc::max2 {args} {
    if { [llength $args]==1 } {set args [lindex $args 0]}
 if { [eq [lindex $args 0] -integer] } { 
	set type integer
	ldelete args 0
    } elseif { [eq [lindex $args 0] -real] } {
	set type real
	ldelete args 0
    } else {
	set type ascii
	foreach value $args {
	    if {[is_integer $value] && [ne $type real]} {
		set type integer
	    } elseif { [is_decimal $value] } {
		set type real
	    } else {
		set type ascii 
		break
	    }
	}
    }
    return [lindex [lsort -$type -decreasing $args] 0]
}

proc qc::mantissa_exponent {x} {
    if { $x==0 } { return [list 0 0] }
    set m $x;set e 0
    while { abs($m) >=10 } { incr e; set m [expr {double($m)/10}] }
    while { abs($m)<1.0 } { incr e -1; set m [expr {$m*10}] }
    return [list $m $e]
}

proc qc::sigfigs {x n} {
    if { $x==0 } { return 0 }
    lassign [mantissa_exponent $x] m e
    set p [expr {pow(10,$e-$n+1)}]
    if { $n-$e-1>0 } {
	return [round [expr {round(double($x)/$p)*$p}] [expr {$n-$e-1}]]
    } else {
	return [round [expr {round(double($x)/$p)*$p}] 0]
    }
}

proc qc::sigfigs_ceil {x n} {
    if { $x==0 } { return 0 }
    lassign [mantissa_exponent $x] m e
    set p [expr {pow(10,$e-$n+1)}]
    if { $n-$e-1>0 } {
	return [round [expr {ceil(double($x)/$p)*$p}] [expr {$n-$e-1}]]
    } else {
	return [round [expr {ceil(double($x)/$p)*$p}] 0]
    }
}
