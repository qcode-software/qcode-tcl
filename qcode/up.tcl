package provide qcode 1.4
package require doc
namespace eval qc {}

proc qc::upcopy { level upname localname } {
    #| Make a local copy of upname
    #| from level $level as $localname
    incr level
    upvar $level $upname value
    upvar 1 $localname localvar
    if { [info exists value] } {
	set localvar $value
    } else {
	if { [info exists localvar] } { unset localvar }
    }
}

proc qc::upset { level upname {upvalue UNDEF}} {
    #| Like set in level $level
    incr level
    upvar $level $upname var
    if { [string equal $upvalue UNDEF] } {
	if { [info exists var] } {
	    return $var
	} else {
	    error "can't read \"$upname\" :no such variable" 
	}
    } else {
	return [set var $upvalue]
    }
}
