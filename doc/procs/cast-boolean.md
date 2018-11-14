qc::cast boolean
================

part of [Cast API](../cast.md)

Usage
-----
`qc::cast boolean string ?true? ?false?`

Description
-----------
Cast a string as a boolean.

Examples
--------
```tcl

% qc::cast boolean YES
t
%
% qc::cast boolean 0
f
%
% qc::cast boolean true Y N
Y

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"