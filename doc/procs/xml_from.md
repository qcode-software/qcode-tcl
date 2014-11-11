qc::xml_from
============

part of [Docs](.)

Usage
-----
`
        qc::xml_from var ?var? ?var? ...
    `

Description
-----------
Return xml structure from the specified local variable names and values

Examples
--------
```tcl

% set name "Angus Jamison"
Angus Jamison
% set number "01311111122"
01311111122
% set xml "<record>[qc::xml_from name number]</record>"
<record><name>Angus Jamison</name>
<number>01311111122</number></record>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"