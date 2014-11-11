qc::widget_combo
================

part of [Docs](.)

Usage
-----
`
	widget_combo name widgetName value Value searchURL url ?boundName widgetName boundValue Value? ?searchLimit 10? ?...?
    `

Description
-----------
Return an DHTML form widget with text input and dropdown for completion.<br>
    Two form variables are bound together using this widget. Normally a string bound to a numeric ID.
    The text input box is bound to a hidden form var for the ID value.

    <h4>name</h4>the name of the input text box
    <h4>value</h4> the initial value of the text box
    <h4>boundName</h4> the name of the hidden form variable bound to this widget.
    <h4>boundValue</h4> the initial value of the bound hidden form variable.
    <h4>searchURL</h4> the URL where we can fetch completion candidates.
    <h4>searchLimit</h4> The maximum number of completion candidates to show.

Examples
--------
```tcl

% widget_combo name customer_code value FOO boundName customer_id boundValue 2343 searchURL customer_combo.xml
widget_combo name customer_code value FOO boundName customer_id boundValue 2343 searchURL customer_combo.xml
<input searchURL="customer_combo.xml" style="width:160px" type="text" id="customer_code" boundName="customer_id" name="customer_code" AUTOCOMPLETE="off" searchLimit="10" boundValue="2343" value="FOO" class="db-form-combo"><input type="hidden" name="customer_id" value="2343">

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


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"