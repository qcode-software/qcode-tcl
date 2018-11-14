qc::castable timestamptz
=========================

part of [Castable API](../castable.md)

Usage
-----
`qc::castable timestamptz string`

Description
-----------
Test if the given string can be cast to a timestamp with timezone.

Examples
--------
```tcl

% qc::castable timestamptz today
true
% qc::castable timestamptz 12/5/12
true
% qc::castable timestamptz foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"