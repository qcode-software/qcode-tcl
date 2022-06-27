namespace eval qc {
    namespace export widget widget_*
}

proc qc::widget {args} {
    #| Look for a proc "widget_$type" to make the widget
    set type [dict get $args type]
    # Check the qc namespace for a widget proc to create the widget type.
    if { [eq [info procs "::qc::widget_$type"] "::qc::widget_$type"] } {
	return ["::qc::widget_$type" {*}$args]
    }

    # No widget proc found in the qc namespace for the type.
    # Check the global namespace for a proc to create the widget type.
    if { [eq [info procs "::widget_$type"] "::widget_$type"] } {
	return ["::widget_$type" {*}$args]
    }
    error "No widget proc defined for $type"
}

proc qc::widget_label { args } {
    #| Return an HTML form label element.
    args_check_required $args name label 
    array set this $args
    default this(id) $this(name)
    set this(for) $this(id)
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }

    set attributes [dict_subset [array get this] for title]
    set html $this(label)
    if {[info exists this(required)] && [string is true $this(required)] } {
        dict set attributes class required
	append html [html span * style "color:#CC0000;"]
    } 

    return [html label $html {*}$attributes]
}

proc qc::widget_text { args } {
    #| Return an HTML form text input widget.
    args_check_required $args name value 

    array set this $args
    set this(type) text
    default this(id) $this(name)
    default this(width) 160
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width)]
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }

    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }

    if { [info exists this(disabled)] && [string is true $this(disabled)] } {
        set this(type) hidden
        set html [html span $this(value) {*}[dict_subset [array get this] title]]
        append html [html_tag input {*}[dict_subset [array get this] type name value id]]
    } else {
	set html [html_tag input {*}[dict_exclude [array get this] required label width units tooltip]]
    }

    return $html
}

proc qc::widget_compare { args } {
    #| Return an HTML form widget with an operator drop down and input box.
    args_check_required $args name value 
    array set this $args
    default this(operator) =
    default this(options) [list "greater than" ">" equals = "less than" "<"]
    default this(sticky) no
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }

    set html [qc::widget_select name $this(name)_op type select value $this(operator) {*}[dict_subset [array get this] options sticky tooltip title]]
    append html " "
    append html [qc::widget_text {*}[qc::dict_exclude [array get this] required operator options sticky]]

    return $html
}

proc qc::widget_combo { args } {
    #| Return an DHTML form widget with text input and dropdown for completion.
    array set this $args
    args_check_required $args name value searchURL
    default this(searchLimit) 10
    set this(class) "db-form-combo"
    set this(AUTOCOMPLETE) off
    set html [qc::widget_text {*}[array get this]]
    if {[info exists this(boundName)]} {
        append html [html_tag input type hidden name $this(boundName) value $this(boundValue)]
    }
    return $html
}

proc qc::widget_htmlarea { args } {
    #| 	Return an HTML form htmlarea widget made from an editable div tag.
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    args_check_required $args name value 
    default this(width) 160
    default this(height) 100
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width) height $this(height)]

    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(contentEditable) true
    set this(class) "db-form-html-area"
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html div $this(value) {*}[qc::dict_exclude [array get this] label required units width height tooltip]]
}

proc qc::widget_textarea { args } {
    #| Return an HTML form textarea element.
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    args_check_required $args name value 
    default this(width) 160
    default this(height) 100
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width) height $this(height)]
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    set html [html textarea $this(value) {*}[qc::dict_exclude [array get this] type value label required units width height tooltip]]
}

proc qc::widget_select { args } {
    #| 	Return an HTML form dropdown list.
    args_check_required $args name value options
    set name_selected "-"
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    default this(null_option) no
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }

    set options_html {}
    if { [string is true $this(null_option)] } {
	lappend options_html "<option value=\"\">- Select -</option>"
    }
    foreach {name value} $this(options) {
	if { [string equal $name $this(value)] || [string equal $value $this(value)] } {
	    set name_selected $name
	    lappend options_html [html option $name value $value selected true]
	} else {
	    lappend options_html [html option $name value $value] 
	}
    }

    if { [info exists this(disabled)] && [string is true $this(disabled)] } {
        set html [html span $name_selected {*}[dict_subset [array get this] title]]
        append html [html_tag input type hidden {*}[dict_subset [array get this] name value id]]
    } else {
        set html [html select [join $options_html \n] {*}[qc::dict_exclude [array get this] required label type options null_option value units tooltip]]
    }

    return $html
}

proc qc::widget_datalist { args } {
    #| 	Return an HTML datalist.
    args_check_required $args name value options
    set name_selected "-"
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    default this(null_option) no
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }

    set options_html {}
    if { [string is true $this(null_option)] } {
	lappend options_html "<option value=\"\">- Select -</option>"
    }
    foreach {name value} $this(options) {
	if { [string equal $name $this(value)] || [string equal $value $this(value)] } {
	    set name_selected $name
	    lappend options_html [html option $name value $value selected true]
	} else {
	    lappend options_html [html option $name value $value] 
	}
    }

    if { [info exists this(disabled)] && [string is true $this(disabled)] } {
        set html [html span $name_selected {*}[dict_subset [array get this] title]]
        append html [html_tag input type hidden {*}[dict_subset [array get this] name value id]]
    } else {
        set html [h input \
                      {*}[qc::dict_exclude [array get this] required label type options null_option value units tooltip] \
                      list $this(id)_datalist \
                     ]
        append html [h datalist \
                         id $this(id)_datalist \
                         [join $options_html \n] \
                        ]
    }

    return $html
}

proc qc::widget_span { args } {
    #| Return a span element showing the value of the widget.
    args_check_required $args name value 
    array set this $args
    
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    # height and width
    if { [info exists this(width)] } {
	set this(style) [qc::style_set [coalesce this(style) ""] width $this(width)]
    }
    if { [info exists this(height)] } {
	set this(style) [qc::style_set [coalesce this(style) ""] height $this(height)]
    }
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html span $this(value) {*}[qc::dict_exclude [array get this] label type value width height tooltip]] 
}

proc qc::widget_password { args } {
    #| Return an HTML form, password input widget.
    args_check_required $args name value
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    set this(type) password
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    default this(width) 160
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width)]
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]]
}

proc qc::widget_bool { args } {
    args_check_required $args name value
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(checked) [true $this(value)]
    # A boolean checkbox ALWAYS has a value of true
    set this(type) checkbox
    set this(value) true
    set this(boolean) true
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]]
}

proc qc::widget_checkbox { args } {
    array set this $args
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(type) checkbox
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]]
}

proc qc::widget_button { args } {
    #| Return an HTML form, button
    args_check_required $args name value
    array set this $args
    set this(type) button
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]]
}

proc qc::widget_submit { args } {
    #| Return an HTML form, submit button
    args_check_required $args name value
    array set this $args
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(type) submit
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]] 
}

proc qc::widget_radio { args } {
    #| Return an HTML form, radio button
    args_check_required $args name value
    array set this $args
    set this(type) radio
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    default this(checked) false
    if { [info exists this(tooltip)] } {
        set this(title) $this(tooltip)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units tooltip]]
}

proc qc::widget_radiogroup { args } {
    args_check_required $args name value options
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] } {
        # sticky values
        if { [info exists this(sticky_url)] && [sticky_exists -url $this(sticky_url) $this(name)] } {
            set this(value) [sticky_get -url $this(sticky_url) $this(name)]
        } elseif { [sticky_exists $this(name)] } {
            set this(value) [sticky_get $this(name)]
        }
    }

    set group_name $this(name)
    set group_value $this(value)
    
    set buttons {}
    foreach {option_name option_value} $this(options) {
	set id ${group_name}${option_value}
	set widget [qc::widget_radio name $group_name value $option_value checked [eq $option_value $group_value] id $id {*}[dict_subset [array get this] title tooltip]]
	set label [qc::widget_label label $option_name name $id {*}[dict_subset [array get this] title tooltip]]
	lappend buttons \
            [h span \
                 style "display:inline-block" \
                 "$widget&nbsp;$label"]
    }
    return [html div [join $buttons "&nbsp; &nbsp;"] class "radio-group" name $group_name id $group_name]
}

proc qc::widget_image_combo { args } {
    #| A widget continaing an image and a combo-input for filenames
    array set this $args
    args_check_required $args name value searchURL imageURL
    default this(searchLimit) 10
    default this(class) "image-combo"
    default this(width) 150
    default this(height) 150
    default this(defaultImage) "/Graphics/noimage.png"
    set style [qc::style_set "" max-width $this(width)px max-height $this(height)px]
    if {$this(value) ne ""} {
        set html [html_tag img src [qc::url $this(imageURL) filename $this(value)] style $style]
    } else {
        set html [html_tag img src $this(defaultImage) style $style]
    }
    append html [qc::widget_text {*}[qc::dict_exclude [array get this] class height type]]
    return [html div $html class $this(class)]
}
