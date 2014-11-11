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
&lt;span class=&quot;true&quot;&gt;Yes&lt;/span&gt;
%
% format_bool No Aye Nay
&lt;span class=&quot;false&quot;&gt;Nay&lt;/span&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"