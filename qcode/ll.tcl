package provide qcode 1.0
package require doc
namespace eval qc {}
proc qc::ll_sum { llVar index } {
    set sum 0
    upvar 1 $llVar ll
    foreach list $ll {
	set value [lindex $list $index]
	set value [ns_striphtml $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

proc qc::ll2csv {ll {comma ,}} {
    set lines {}
    foreach list $ll {
	lappend lines [qc::list2csv $list $comma]
    }
    return [join $lines \r\n]
}
