qc::cast_boolean
================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast_boolean string ?true? ?false?`

Description
-----------
Deprecated - see [qc::cast boolean][1]
Cast a string as a boolean

Examples
--------
```tcl

% cast_boolean YES
t
%
% cast_boolean 0
f
%
% cast_boolean true Y N
Y

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[1]: cast-boolean.md