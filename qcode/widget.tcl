package provide qcode 1.15
package require doc
namespace eval qc {}

proc qc::widget {args} {
    #| Look for a proc "widget_$type" to make the widget
    set type [dict get $args type]
    if { [eq [info procs "::qc::widget_$type"] "::qc::widget_$type"] } {
	return ["::qc::widget_$type" {*}$args]
    } 
    if { [eq [info procs "widget_$type"] "widget_$type"] } {
	return ["widget_$type" {*}$args]
    } 
    error "No widget proc defined for $type"
}

doc qc::widget {
    Description {
        Look for a proc "widget_$type" to make the widget
    }
    Usage {
	widget name widgetName label labelText ?required yes?
    }
    Examples {
        % qc::widget type text name textWidget value "Horses"
        <input style="width:160px" id="textWidget" value="Horses" name="textWidget" type="text">

        % qc::widget type label name labelWidget label "This is a label"
        <label for="labelWidget">This is a label</label>

        % qc::widget type quantum name quantumWidget value "Everything" 
        No widget proc defined for quantum
    }
}

proc qc::widget_label { args } {
    #| Return an HTML form label element.
    args_check_required $args name label 
    array set this $args
    default this(id) $this(name)
    if {[info exists this(required)] && [string is true $this(required)] } {
	return [html label "$this(label)<span style=\"color:#CC0000\">*</span>" for $this(id) class clsRequired]
    } else {
	return [html label $this(label) for $this(id)]
    }
}

doc qc::widget_label {
    Usage {
	widget_label name widgetName label labelText ?required yes?
    }
    Examples {
	% widget_label name firstname label Firstname
	<label for="firstname">Firstname</label>
	
	# Required form elements have a css class applied and a red asterisk.
	# Hack the code to make it look different.
	% widget_label name surname label Surname required yes
	<label for="surname" class="clsRequired">Surname<span style="color:#CC0000">*</span></label>
    }
}

proc qc::widget_text { args } {
    #| Return an HTML form text input widget.
    args_check_required $args name value 
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    set this(type) text
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    default this(width) 160
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width)]
    if { [info exists this(disabled)] && [string is true $this(disabled)] } {
	return [html span $this(value)][html_tag input type hidden name $this(name) value $this(value) id $this(id)]
    } else {
	return [html_tag input {*}[qc::dict_exclude [array get this] required label width units]]
    }
}

doc qc::widget_text {
    Usage {
	widget_text name widgetName value Value ?id ID? ?width pixels? ...
    }
    Examples {
	% widget_text name firstname value "" id firstname width 400
	<input style="width:400px" id="firstname" value="" name="firstname" type="text">

	# Disabled text controls are shown as non-editable text plus hidden form variable to pass the form variable.
	% widget_text name firstname value "Jimmy" id firstname disabled yes
	<span>Jimmy</span><input type="hidden" name="firstname" value="Jimmy" id="firstname">
    }
}

proc qc::widget_compare { args } {
    #| Return an HTML form widget with an operator drop down and input box.
    args_check_required $args name value 
    array set this $args
    default this(operator) =
    default this(options) [list "greater than" ">" equals = "less than" "<"]
    default this(sticky) no
    set html [qc::widget_select name $this(name)_op type select options $this(options) value $this(operator) sticky $this(sticky)]
    append html " "
    append html [qc::widget_text {*}[qc::dict_exclude $args required operator options sticky]]

    return $html
}

doc qc::widget_compare {
    Usage {
	widget_compare name widgetName value Value ?operator Operator? ?...?
    }
    Examples {
	% widget_compare name price value 10 operator =
	widget_compare name price value 10 operator =
	<select id="price_op" name="price_op">
	<option value="&gt;">greater than</option>
	<option value="=" selected>equals</option>
	<option value="&lt;">less than</option>
	</select>
	<input style="width:160px" id="price" value="10" name="price" type="text">
    }
}

proc qc::widget_combo { args } {
    #| Return an DHTML form widget with text input and dropdown for completion.
    array set this $args
    args_check_required $args name value searchURL
    default this(searchLimit) 10
    set this(class) clsDbFormCombo
    set this(AUTOCOMPLETE) off
    set html [qc::widget_text {*}[array get this]]
    if {[info exists this(boundName)]} {
        append html [html_tag input type hidden name $this(boundName) value $this(boundValue)]
    }
    return $html
}

doc qc::widget_combo {
    Usage {
	widget_combo name widgetName value Value searchURL url ?boundName widgetName boundValue Value? ?searchLimit 10? ?...?
    }
    Description {
	Return an DHTML form widget with text input and dropdown for completion.<br>
	Two form variables are bound together using this widget. Normally a string bound to a numeric ID.
	The text input box is bound to a hidden form var for the ID value.

	<h4>name</h4>the name of the input text box
	<h4>value</h4> the initial value of the text box
	<h4>boundName</h4> the name of the hidden form variable bound to this widget.
	<h4>boundValue</h4> the initial value of the bound hidden form variable.
	<h4>searchURL</h4> the URL where we can fetch completion candidates.
	<h4>searchLimit</h4> The maximum number of completion candidates to show.
    }
   
    Examples {
	% widget_combo name customer_code value FOO boundName customer_id boundValue 2343 searchURL customer_combo.xml
	widget_combo name customer_code value FOO boundName customer_id boundValue 2343 searchURL customer_combo.xml
	<input searchURL="customer_combo.xml" style="width:160px" type="text" id="customer_code" boundName="customer_id" name="customer_code" AUTOCOMPLETE="off" searchLimit="10" boundValue="2343" value="FOO" class="clsDbFormCombo"><input type="hidden" name="customer_id" value="2343">
	
	% https://a-domain.co.uk/customer_combo.xml?name=customer_code&value=A&boundName=customer_id&searchLimit=10
	
	<records>
	<record>
	<customer_code>A & R PLUMBING</customer_code>
	<customer_id>27706</customer_id>
	</record>
	<record>
	<customer_code>A W PLUMBERS</customer_code>
	<customer_id>278004</customer_id>
	</record>
	<record>
	<customer_code>A&A PLUMBERS</customer_code>
	<customer_id>21162</customer_id>
	</record>
	<record>
	<customer_code>A&G PLUMING SUPPLIES</customer_code>
	<customer_id>2819</customer_id>
	</record>
	<record>
	<customer_code>A&J THOMPSON</customer_code>
	<customer_id>2083</customer_id>
	</record>
	<record>
	<customer_code>A&J KEITH SMITH</customer_code>
	<customer_id>2469</customer_id>
	</record>
	<record>
	<customer_code>A1</customer_code>
	<customer_id>3758</customer_id>
	</record>
	<record>
	<customer_code>A1 FIFE</customer_code>
	<customer_id>308993</customer_id>
	</record>
	<record>
	<customer_code>ABACUS PERTH</customer_code>
	<customer_id>2466</customer_id>
	</record>
	<record>
	<customer_code>ABBEY KNIFE</customer_code>
	<customer_id>3627</customer_id>
	</record>
	</records>

    }
}

proc qc::widget_htmlarea { args } {
    #| 	Return an HTML form htmlarea widget made from an editable div tag.
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    args_check_required $args name value 
    default this(width) 160
    default this(height) 100
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width) height $this(height)]

    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(contentEditable) true
    set this(class) clsDbFormHTMLArea
    return [html div $this(value) {*}[qc::dict_exclude [array get this] label required units width height]]
}

doc qc::widget_htmlarea {
    Usage {
	widget_htmlarea name widgetName value html ?width size? ?height size? ?..?
    }
    Examples {
	% widget_htmlarea name notes value "A <i>little</i> note."
	<div contentEditable="true" id="notes" style="width:160px;height:100px" value="A &lt;i&gt;little&lt;/i&gt; note." name="notes" class="clsDbFormHTMLArea">A <i>little</i> note.</div>
    }
}

proc qc::widget_textarea { args } {
    #| Return an HTML form textarea element.
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    args_check_required $args name value 
    default this(width) 160
    default this(height) 100
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width) height $this(height)]
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set html [html textarea $this(value) {*}[qc::dict_exclude [array get this] type value label required units width height]]
}

doc qc::widget_textarea {
    Usage {
	widget_textarea name widgetName value text ?width size? ?height size? ?..?
    }
    Examples {
	% widget_textarea name notes value "Hi There"
        <div contentEditable="true" id="notes" style="width:160px;height:100px" value="Hi There" name="notes" class="clsDbFormHTMLArea">Hi There</div>
    }
}

proc qc::widget_select { args } {
    #| 	Return an HTML form dropdown list.
    args_check_required $args name value options
    set name_selected "-"
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    default this(null_option) no
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set html [html_tag select {*}[qc::dict_exclude [array get this] required label type options null_option value units]]
    append html \n
    if { [string is true $this(null_option)] } {
	append html "<option value=\"\">- Select -</option>\n"
    }
    foreach {name value} $this(options) {
	if { [string equal $name $this(value)] || [string equal $value $this(value)] } {
	    set name_selected $name
	    append html [html option $name value $value selected true] \n
	} else {
	    append html [html option $name value $value] \n
	}
    }
    append html "</select>\n"
    if { [info exists this(disabled)] && [string is true $this(disabled)] } {
	return [html span $name_selected][html_tag input type hidden name $this(name) value $this(value) id $this(id)]
    } else {
	return $html
    }
}

doc qc::widget_select {
    Usage {
	widget_select name widgetName value text options {name value name value ...} ?null_option yes/no?
    }
    Description {
	Return an HTML form dropdown list.
	<h4>options</h4>
	The options arg is a name value list that is used to contruct the dropdown options.
	Two helper procs are:-<br>
	<proc>html_options_simple</proc><br>
	<proc>html_options_db</proc>
    }
    Examples {
	% widget_select name letter value "" options {Alpha A Bravo B Charlie C} null_option yes
	<select id="letter" name="letter">
	<option value="">- Select -</option>
	<option value="A">Alpha</option>
	<option value="B">Bravo</option>
	<option value="C">Charlie</option>
	</select>
    }
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
    return [html span $this(value) {*}[qc::dict_exclude [array get this] label type value width height]] 
}

doc qc::widget_span {
    Usage {
	widget_span name widgetName value text ?width size? ?height size?
    }
    Examples {
	% widget_span name foo value bar
	<span id="foo">bar</span>
    }
}

proc qc::widget_password { args } {
    #| Return an HTML form, password input widget.
    args_check_required $args name value
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    set this(type) password
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    default this(width) 160
    set this(style) [qc::style_set [coalesce this(style) ""] width $this(width)]
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]]
}

doc qc::widget_password {
    Usage {
	widget_text name widgetName value Value ?id ID? ?width pixels? ...
    }
    Examples {
	% widget_password name password value "" 
	<input style="width:160px" id="password" value="" name="password" type="password">
    }
}

proc qc::widget_bool { args } {
    args_check_required $args name value
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(checked) [true $this(value)]
    # A boolean checkbox ALWAYS has a value of true
    set this(type) checkbox
    set this(value) true
    set this(boolean) true
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]]
}

doc qc::widget_bool {
    Usage {
	widget_bool name widgetName value Value ?id ID? 
    }
    Description {
	Return an HTML form, checkbox input widget.<br>
	The difference between widget_bool and widget_checkbox is that widget_bool always returns the value "true" if checked.<br>
	The checkbox is checked if the value passed to widget_bool is true.
    }
    Examples {
	% widget_bool name spam value no
	<input boolean="true" id="spam" value="true" name="spam" type="checkbox">

	% widget_bool name spam value yes
	<input boolean="true" id="spam" value="true" name="spam" type="checkbox" checked>
    }
}

proc qc::widget_checkbox { args } {
    array set this $args
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(type) checkbox
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]]
}

doc qc::widget_checkbox {
    Usage {
	widget_checkbox name widgetName value Value ?id ID? 
    }
    Description {
	Return an HTML form, checkbox input widget.<br>
	Sometimes used against a list of documents all using the same variable name. The POST is then interpreted as a list of say ID's that have been ticked.
    }
    Examples {
	% widget_checkbox name order_no value 3215
	<input id="order_no" value="3215" name="order_no" type="checkbox">
	
    }
}

proc qc::widget_button { args } {
    #| Return an HTML form, button
    args_check_required $args name value
    array set this $args
    set this(type) button
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]]
}

doc qc::widget_button {
    Usage {
	widget_button name widgetName value buttonText ?option value? ?..?
    }
    Examples {
	widget_button name foo value "Click Me" onclick "alert('Hi');"
	<input id="foo" value="Click Me" name="foo" type="button" onclick="alert('Hi');">
    }
}

proc qc::widget_submit { args } {
    #| Return an HTML form, submit button
    args_check_required $args name value
    array set this $args
    if { [info exists this(name)] } { 
	default this(id) $this(name)
    }
    set this(type) submit
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]] 
}

doc qc::widget_submit {
    Usage {
	widget_submit name widgetName value buttonText ?option value? ?..?
    }
    Examples {
	widget_submit name foo value "Submit"
	<input id="foo" value="Submit" name="foo" type="submit">
    }
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
    return [html_tag input {*}[qc::dict_exclude [array get this] label width height units]]
}

doc qc::widget_radio {
    Usage {
	widget_radio name widgetName value checkedValue ?option value? ?..?
    }
    Examples {
	widget_radio name sex value male
	<input id="sex" value="male" name="sex" type="radio">
    }
}

proc qc::widget_radiogroup { args } {
    args_check_required $args name value options
    array set this $args
    if { [info exists this(sticky)] && [true $this(sticky)] && [sticky_exists $this(name)] } {
	# sticky values
	set this(value) [sticky_get $this(name)]
    }

    set group_name $this(name)
    set group_value $this(value)
    
    set buttons {}
    foreach {option_name option_value} $this(options) {
	set id ${group_name}${option_value}
	set widget [qc::widget_radio name $group_name value $option_value checked [eq $option_value $group_value] id $id]
	set label [qc::widget_label label $option_name name $id]
	lappend buttons "$widget&nbsp;$label"
    }
    return [html div [join $buttons "&nbsp; &nbsp;"] class clsRadioGroup name $group_name id $group_name]
}

doc qc::widget_radiogroup {
    Usage {
	widget_radiogroup name widgetName value checkedValue options {name value name value ...} ?..?
    }
    Description {
	Return an HTML form, radio button group
    }
    Examples {
	widget_radiogroup name sex value M options {Male M Female F}
	<div class="clsRadioGroup" name="sex" id="sex">
	<input id="sexM" value="M" name="sex" type="radio" checked>&nbsp;<label for="sexM">Male</label>
	&nbsp; &nbsp;
	<input id="sexF" value="F" name="sex" type="radio">&nbsp;<label for="sexF">Female</label>
	</div>
    }
}

proc qc::widget_image_combo { args } {
    #| A widget continaing an image and a combo-input for filenames
    array set this $args
    args_check_required $args name value searchURL imageURL
    default this(searchLimit) 10
    default this(class) imageCombo
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