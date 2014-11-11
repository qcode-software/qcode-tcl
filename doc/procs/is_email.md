qc::is_email
============

part of [Docs](.)

Usage
-----
`qc::is_email email`

Description
-----------


Examples
--------
```tcl

% qc::is_email @gmail.com
0
% qc::is_email dave.@gmail.com
0
% qc::is_email dave@gmail
0
% qc::is_email dave.smith@gmail.co.uk
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"