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
&lt;input searchURL=&quot;customer_combo.xml&quot; style=&quot;width:160px&quot; type=&quot;text&quot; id=&quot;customer_code&quot; boundName=&quot;customer_id&quot; name=&quot;customer_code&quot; AUTOCOMPLETE=&quot;off&quot; searchLimit=&quot;10&quot; boundValue=&quot;2343&quot; value=&quot;FOO&quot; class=&quot;db-form-combo&quot;&gt;&lt;input type=&quot;hidden&quot; name=&quot;customer_id&quot; value=&quot;2343&quot;&gt;

% https://a-domain.co.uk/customer_combo.xml?name=customer_code&amp;value=A&amp;boundName=customer_id&amp;searchLimit=10

&lt;records&gt;
&lt;record&gt;
&lt;customer_code&gt;A &amp; R PLUMBING&lt;/customer_code&gt;
&lt;customer_id&gt;27706&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A W PLUMBERS&lt;/customer_code&gt;
&lt;customer_id&gt;278004&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A&amp;A PLUMBERS&lt;/customer_code&gt;
&lt;customer_id&gt;21162&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A&amp;G PLUMING SUPPLIES&lt;/customer_code&gt;
&lt;customer_id&gt;2819&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A&amp;J THOMPSON&lt;/customer_code&gt;
&lt;customer_id&gt;2083&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A&amp;J KEITH SMITH&lt;/customer_code&gt;
&lt;customer_id&gt;2469&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A1&lt;/customer_code&gt;
&lt;customer_id&gt;3758&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;A1 FIFE&lt;/customer_code&gt;
&lt;customer_id&gt;308993&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;ABACUS PERTH&lt;/customer_code&gt;
&lt;customer_id&gt;2466&lt;/customer_id&gt;
&lt;/record&gt;
&lt;record&gt;
&lt;customer_code&gt;ABBEY KNIFE&lt;/customer_code&gt;
&lt;customer_id&gt;3627&lt;/customer_id&gt;
&lt;/record&gt;
&lt;/records&gt;


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"