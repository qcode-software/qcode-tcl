qc::trunc
=========

part of [Docs](../index.md)

Usage
-----
`
        qc::trunc string length
    `

Description
-----------
Truncates string to specified length

Examples
--------
```tcl

% set string "This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately."
This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.
% set string_varchar50 [qc::trunc $string 50]
This is a longer string than would be allowed in v
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"