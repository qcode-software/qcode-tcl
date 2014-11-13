qc::widget_text
===============

part of [Docs](../index.md)

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

% widget_text name firstname value "" id firstname width 400
<input style="width:400px" id="firstname" value="" name="firstname" type="text">

# Disabled text controls are shown as non-editable text plus hidden form variable to pass the form variable.
% widget_text name firstname value "Jimmy" id firstname disabled yes
<span>Jimmy</span><input type="hidden" name="firstname" value="Jimmy" id="firstname">

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"