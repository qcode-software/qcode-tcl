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
<label for="firstname">Firstname</label>

    # Required form elements have a css class applied and a red asterisk.
# Hack the code to make it look different.
% widget_label name surname label Surname required yes
<label for="surname" class="required">Surname<span style="color:#CC0000">*</span></label>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"