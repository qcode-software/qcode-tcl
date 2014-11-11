qc::widget_button
=================

part of [Docs](.)

Usage
-----
`
	widget_button name widgetName value buttonText ?option value? ?..?
    `

Description
-----------
Return an HTML form, button

Examples
--------
```tcl

widget_button name foo value &quot;Click Me&quot; onclick &quot;alert(&#39;Hi&#39;);&quot;
&lt;input id=&quot;foo&quot; value=&quot;Click Me&quot; name=&quot;foo&quot; type=&quot;button&quot; onclick=&quot;alert(&#39;Hi&#39;);&quot;&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"