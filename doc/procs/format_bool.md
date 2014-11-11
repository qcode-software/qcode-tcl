qc::format_bool
===============

part of [Docs](.)

Usage
-----
`qc::format_bool value ?true? ?false?`

Description
-----------
Cast boolean and wrap in span tags with style

Examples
--------
```tcl

% format_bool Y 
<span class="true">Yes</span>
%
% format_bool No Aye Nay
<span class="false">Nay</span>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"