qc::widget_label
================

part of [Docs](.)

Usage
-----
`
	widget_label name widgetName label labelText ?required yes?
    `

Description
-----------
Return an HTML form label element.

Examples
--------
```tcl

% widget_label name firstname label Firstname
&lt;label for=&quot;firstname&quot;&gt;Firstname&lt;/label&gt;

    # Required form elements have a css class applied and a red asterisk.
# Hack the code to make it look different.
% widget_label name surname label Surname required yes
&lt;label for=&quot;surname&quot; class=&quot;required&quot;&gt;Surname&lt;span style=&quot;color:#CC0000&quot;&gt;*&lt;/span&gt;&lt;/label&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"