qc::is_mobile_number
====================

part of [Docs](.)

Usage
-----
`qc::is_mobile_number string`

Description
-----------


Examples
--------
```tcl

% qc::is_mobile_number &quot; 0 7  986 21299     9&quot;
true
% qc::is_mobile_number 09777112112
false
% qc::is_mobile_number 013155511111
false
% qc::is_mobile_number 07512122122
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"