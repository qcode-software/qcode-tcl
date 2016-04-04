namespace eval qc {
    namespace export bs_form_layout_*
}

proc qc::bs_form_layout_capsule {args} {
    #| Constructs a bootstrap floating label form layout with labels 
    # and form elements
    args $args -- conf
    
    set level 1
    set body [list]
    
    foreach dict $conf {
	array set this $dict	
	default this(type) text

	if { ![info exists this(value)] } {
	    qc::upcopy $level $this(name) value
	    if {[info exists value]} {
		set this(value) $value
	    } else {
		set this(value) ""
	    }
	}
	if {[info procs "::qc::bs_capsule_$this(type)"] ne "::qc::bs_capsule_$this(type)"} {
	    error "No widget proc defined for $this(type)"
	}

	lappend body ["qc::bs_capsule_$this(type)" {*}[array get this]]
	
	unset this
	
    }
    return [join $body "\n"]
}
