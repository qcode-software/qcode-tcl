qc::setif
=========

part of [Docs](../index.md)

Usage
-----
`
        qc::setif varName ifValue defaultValue
    `

Description
-----------
Set varName to be defaultValue if varName is set to ifValue or does not exist

Examples
--------
```tcl

% set background-color
NULL
% qc::setif background-color NULL white
white
% set background-color
white
% set background-color red
red
% qc::setif background-color NULL white
%
% set background-color
red
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"