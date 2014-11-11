qc::widget_text
===============

part of [Docs](.)

Usage
-----
`
	widget_text name widgetName value Value ?id ID? ?width pixels? ...
    `

Description
-----------
Return an HTML form text input widget.

Examples
--------
```tcl

% widget_text name firstname value &quot;&quot; id firstname width 400
&lt;input style=&quot;width:400px&quot; id=&quot;firstname&quot; value=&quot;&quot; name=&quot;firstname&quot; type=&quot;text&quot;&gt;

# Disabled text controls are shown as non-editable text plus hidden form variable to pass the form variable.
% widget_text name firstname value &quot;Jimmy&quot; id firstname disabled yes
&lt;span&gt;Jimmy&lt;/span&gt;&lt;input type=&quot;hidden&quot; name=&quot;firstname&quot; value=&quot;Jimmy&quot; id=&quot;firstname&quot;&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"