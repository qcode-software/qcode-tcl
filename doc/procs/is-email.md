qc::is email
============

part of [Is API](../is.md)

Usage
-----
`qc::is email email`

Description
-----------
Checks if the given string follows the form of an email address.

Examples
--------
```tcl

% qc::is email @gmail.com
0
% qc::is email dave.@gmail.com
0
% qc::is email dave@gmail
0
% qc::is email dave.smith@gmail.co.uk
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"