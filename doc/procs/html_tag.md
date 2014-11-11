qc::html_tag
============

part of [Docs](../index.md)

Usage
-----
`qc::html_tag tagName args`

Description
-----------
Generate just the opening html tag

Examples
--------
```tcl

% html_tag input name firstname
<input name="firstname">
%
% html_tag input name firstname value "Des O'Conner"
<input name="firstname" value="Des O'Conner">
%
% html_tag input name firstname value "Des O'Conner" disabled yes
<input name="firstname" value="Des O'Conner" disabled>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"