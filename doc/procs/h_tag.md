qc::h_tag
============

part of [Docs](../index.md)

Usage
-----
`qc::h_tag tag_name args`

Description
-----------
Generate just the opening html tag. If the tag_name given is a void element then close it with "/".

Examples
--------
```tcl

% h_tag div id first
<div id="first">
%
% h_tag input name firstname value "Des O'Conner" disabled yes
<input name="firstname" value="Des O'Conner" disabled="disabled"/>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"