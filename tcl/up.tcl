namespace eval qc {
    namespace export upcopy upset
}

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

proc qc::upset {level upname args} {
    #| Like set in level $level
    if { [regexp {::} $upname] } {
        return -code error "Will not set variable outside specified\
        namespace."
    }
    
    incr level
    upvar $level $upname var
    switch [llength $args] {
        1 {
            return [set var [lindex $args 0]]
        }
        0 {
            if { [info exists var] } {
                return $var
            } else {
                error "can't read \"$upname\" :no such variable" 
            }
        }
        default {
            error "Usage qc::upset level upname ?upvalue?"
        }
    }
}
