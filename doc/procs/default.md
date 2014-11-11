qc::default
===========

part of [Docs](.)

Usage
-----
`default varName defaultValue ?varName defaultValue? ...`

Description
-----------
If a variable does not exists then set its value to <i>defaultValue</i>

Examples
--------
```tcl

% set foo 1
% default foo 2
1
# foo is unaffected
% 
% default bar Yes
Yes
% set bar
Yes

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"