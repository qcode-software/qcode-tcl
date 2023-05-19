proc qc::is::creditcard {number} {
    #| Checks if the given string is an allowable credit card number.
    #| Checks, number of digits are >13 & <19, all characters are integers,
    #| luhn 10 check
    regsub -all {[ -]} $number "" number
    set mult 1
    set sum 0
    if { [string length $number]<13 || [string length $number]>19 } {
        return 0
    }
    foreach digit [lreverse [split $number ""]] {
        if { ![qc::is integer $digit] } {
            return 0
        }
        set t [expr {$digit*$mult}]
        if { $t >= 10 } {
            set sum [expr {$sum + $t%10 +1}]
        } else {
            set sum [expr {$sum + $t}]
        }
        if { $mult == 1 } { set mult 2 } else { set mult 1 }
    }
    if { $sum%10 == 0 } {
        return 1
    } else {
        return 0
    }
}

proc qc::is::creditcard_masked {string} {
    #| Check the credit card number is masked to PCI requirements.
    regsub -all {[^0-9\*]} $string "" number

    # 13-19 chars masked with < 6 prefix and < 4 suffix digits
    return [expr {[regexp {[0-9\*]{13,19}} $number]
                  && [regexp {^[3-6\*][0-9]{0,5}\*+[0-9]{0,4}$} $number]}]
}
