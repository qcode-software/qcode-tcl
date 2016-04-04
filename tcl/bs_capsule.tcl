namespace eval qc {
    namespace export bs_capsule_*
}

proc qc::bs_capsule_text {args} {
    #| Returns bootstrap floating label form group for text input
    args_check_required $args name value label
    array set this $args
    set this(type) text
    default this(id) $this(name)

    set group [list]
    lappend group [h label for $this(id) $this(label)]
    lappend group [h input type $this(type) class "form-control" placeholder $this(label) value $this(value) name $this(name) id $this(id)]
    if {[info exist this(unit)]} {
	lappend group [h span class "help-block help-block-inline help-block-background" $this(unit)]
    }
    return [h div class "form-group" [join $group \n]]

}

proc qc::bs_capsule_password {args} {
    #| Returns bootstrap floating label form group for password input
    args_check_required $args name value label
    array set this $args
    set this(type) password
    default this(id) $this(name)

    set group [list]
    lappend group [h label for $this(id) $this(label)]
    lappend group [h input type $this(type) class "form-control" placeholder $this(label) value $this(value) name $this(name) id $this(id)]
    return [h div class "form-group" [join $group \n]]

}


proc qc::bs_capsule_select {args} {
    #| Returns bootstrap floating label form group for dropdown
    args_check_required $args name value options label
    array set this $args
    default this(id) $this(name)
    default this(null_option) no

    set group [list]
    lappend group [h label for $this(id) $this(label)]
    set dropdown [qc::widget_select name $this(name) id $this(id) value $this(value) options $this(options) class "form-control" null_option $this(null_option)]
    lappend group [h div class "select-wrapper" $dropdown]

    return [h div class "form-group form-group-select" [join $group \n]]
}

proc qc::bs_capsule_textarea {args} {
    #| Returns bootstrap floating label form group for textarea
    args_check_required $args name value label
    array set this $args
    default this(id) $this(name)
    default this(rows) 25

    set group [list]
    lappend group [h label for $this(id) $this(label)]
    lappend group [h textarea class "form-control" rows $this(rows) placeholder $this(label)  name $this(name) id $this(id) $this(value)]
    return [h div class "form-group form-group-textarea" [join $group \n]]
}

proc qc::bs_capsule_button {args} {
    #| Returns bootstrap form group for button 
    array set this $args
    default this(type) submit
    default this(label) Submit
    
    return [h button type $this(type) class "btn btn-default" $this(label)]    
}

proc qc::bs_capsule_markdown {args} {
    #| Returns bootstrap tab group for markdown write/preview
    # CSS classes to style: markdown-preview, markdown-upload-button
    # Markdown target id: $this(id)-result
    args_check_required $args name value label
    array set this $args
    default this(id) $this(name)
    #default this(rows) 25

    set group [list]

    
    # Navbar tab for write/preview
    set tab [list]
    lappend tab [h li class "active" [h a href "#$this(id)-write" data-toggle "tab" "Write"]]
    lappend tab [h li [h a href "#$this(id)-preview" data-toggle "tab" "Preview"]]
    set tab [h ul class "nav nav-tabs" [join $tab \n]]
    
    # Label
    lappend group [h label for $this(id) $this(label)]
    # Textarea
    lappend group [h textarea class "form-control" placeholder $this(label) name $this(name) id $this(id) $this(value)]
    set upload_button [h span class "markdown-upload-button" "selecting"]
    lappend group [h span class "help-block" "Add images by draggin & dropping, $upload_button, pasting"] 
   
    # Tab content 
    set content [list]
    lappend content [h div class "tab-pane active" id "$this(id)-write" [h div class "form-group form-group-markdown" [join $group \n]]]
    lappend content [h div class "tab-pane" id "$this(id)-preview" [h div id "$this(id)-result" class "markdown-preview" ]]
    set content [h div class "tab-content" [join $content \n]]

    return [h div ${tab}${content}]

}

proc qc::bs_capsule_checkbox {args} {
    #| Returns bootstrap falvoured checkbox
    args_check_required $args name value label
    array set this $args
    default this(id) $this(name)
    set this(type) checkbox
    set this(checked) [true $this(value)]

    set checkbox [h input {*}[qc::dict_exclude [array get this] label]]
    return [h div class checkbox [h label ${checkbox}$this(label)]]
}