proc qc::is::decimal {args} {
    #| Checks if the given number is a decimal.
    qc::args $args -precision ? -scale ? -- string
    if {[string is double -strict $string]} {
        if { ! [info exists precision] && ! [info exists scale] } {
            # Scale and precision not given.
            return 1
        } elseif { ! [info exists precision] && [info exists scale] } {
            # Scale given but not precision.
            return -code error "Precision must be provided with scale."
        } elseif { [info exists precision] } {
            # Precision given.
            if { $precision <= 0 || ! [qc::is integer $precision]} {
                return -code error "Precision must be a positive integer."
            }
            # Count the number of digits before and after the decimal point.
            set number [qc::exp2string $string]
            set parts [split $number .]
            set left_count [string length [lindex $parts 0]]
            set right_count [string length [lindex $parts 1]]
            if { $left_count == 0 } {
                # The leading zero wasn't given.
                return -code error "Incomplete numeric string."
            }

            set total_count [expr {$left_count + $right_count}]
            if { $precision < $total_count } {
                # Precision is less than the total number of digits in the given
                # decimal.
                return 0
            }
            
            if { ! [info exists scale] } {
                # Scale wasn't given so set it to 0.
                set scale 0
            }

            if { $scale < 0 || ! [qc::is integer $scale]} {
                return -code error "Scale must be a non-negative integer."
            }

            set left_digit_max [expr {$precision - $scale}]
            if { $left_count > $left_digit_max || $right_count > $scale } {
                return 0
            } else {
                return 1
            }
            
        }
    } else {
        return 0
    }
}
