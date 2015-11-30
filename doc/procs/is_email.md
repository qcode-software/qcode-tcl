qc::is_email
============

part of [Docs](../index.md)

Usage
-----
`qc::is_email email`

Description
-----------
Deprecated - see [qc::is email]

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
[qc::is email]: is-email.md