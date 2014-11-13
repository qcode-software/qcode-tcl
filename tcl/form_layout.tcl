namespace eval qc {
    namespace export form_layout_*
}

proc qc::form_layout_table { args } {
    #| Construct an html table with 2 columns for labels and form elements
    args $args -sticky -class "form-layout-table" -- conf
    set cols {
	{class label}
	{}
    }
    if { [info exists sticky] } {
	set tbody [uplevel 1 [list qc::form_layout_tbody -sticky -- $conf]]
    } else {
	set tbody [uplevel 1 [list qc::form_layout_tbody $conf]]
    }
    return [qc::html_table cols $cols class $class tbody $tbody]
}

proc qc::form_layout_tables { args } {
    #| Construct multi-column layout with a form table in each column
    args $args -sticky -- args
    set cols {
	{class label}
	{}
    }
    set class "form-layout-table"
    foreach conf $args {
	if { [info exists sticky] } {
	    set tbody [uplevel 1 [list qc::form_layout_tbody -sticky -- $conf]]
	} else {
	    set tbody [uplevel 1 [list qc::form_layout_tbody $conf]]
	}
	lappend row [qc::html_table cols $cols class $class tbody $tbody]
    }
    set class "columns-container"
    set tbody [list $row]
    return [qc::html_table class $class tbody $tbody]
}
    
proc qc::form_layout_tbody { args } {
    #| Construct a 2-column tbody for form elements.
    #| For most input elements the label is shown on the left and input element on the right.
    #| Exceptions for checkboxes and radiogroup.
    args $args -sticky -- conf
    set level 1
    set tbody {}
    foreach dict $conf {
	array set this $dict
	default this(label) Unknown
	default this(type) text
	# sticky used if set for the widget or globally
	# can be turned off for the widget by setting "sticky no"
	if { [info exists sticky] } {
	    default this(sticky) yes
	} else {
	    default this(sticky) no
	}
	if {[true $this(sticky)] && [sticky_exists $this(name)]} {
	    # sticky values
	    set this(value) [sticky_get $this(name)]
	}
	if { ![info exists this(value)]} {
	    # check caller variable for value
	    qc::upcopy $level $this(name) value
	    if { [info exists value] } {
		set this(value) $value
	    } else {
		set this(value) ""
	    }
	}
    
	
	switch $this(type) {
	    checkbox -
	    bool {
		lappend tbody [list "" "[qc::widget {*}[array get this]] [qc::widget_label {*}[array get this]]"]
	    }
	    radiogroup {
		lappend tbody [list [qc::widget_label {*}[array get this]] [qc::widget_radiogroup {*}[array get this]]]
	    }
	    default {
		set cell [qc::widget {*}[array get this]]
		if { [info exists this(units)] } {
		    append cell [html span " $this(units)"]
		} 
		lappend tbody [list [qc::widget_label {*}[array get this]] $cell]
	    }
	}

	unset this
    }
    return $tbody
}

proc qc::form_layout_list {conf} {
    #| Layout the form elements in the conf with input elements below labels.
    set level 1
    set html {}
    foreach dict $conf {
	array set this $dict
	default this(label) Unknown
	default this(type) text
	if { ![info exists this(value)]} {
	    qc::upcopy $level $this(name) value
	    if { [info exists value] } {
		set this(value) $value
	    } else {
		set this(value) ""
	    }
	}

	set label [qc::widget_label {*}[array get this]]

	set widget [qc::widget {*}[array get this]]

	if { [in {checkbox bool} $this(type)] } {
	    append html "<div style=\"padding-bottom:1em;\">$widget $label</div>"
	} else {
	    set lines {}
	    if { [ne $this(label) ""] } { lappend lines $label }
	    if { [info exists this(note)] } { lappend lines $this(note) }
	    lappend lines $widget
	    append html "<div style=\"padding-bottom:1em;\">[join $lines "<br>"]</div>"
	}
	unset this
    }
    return $html
}

