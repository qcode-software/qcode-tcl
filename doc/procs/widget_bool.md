qc::widget_bool
===============

part of [Docs](.)

Usage
-----
`
	widget_bool name widgetName value Value ?id ID? 
    `

Description
-----------
Return an HTML form, checkbox input widget.<br>
    The difference between widget_bool and widget_checkbox is that widget_bool always returns the value "true" if checked.<br>
    The checkbox is checked if the value passed to widget_bool is true.

Examples
--------
```tcl

% widget_bool name spam value no
&lt;input boolean=&quot;true&quot; id=&quot;spam&quot; value=&quot;true&quot; name=&quot;spam&quot; type=&quot;checkbox&quot;&gt;

% widget_bool name spam value yes
&lt;input boolean=&quot;true&quot; id=&quot;spam&quot; value=&quot;true&quot; name=&quot;spam&quot; type=&quot;checkbox&quot; checked&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"