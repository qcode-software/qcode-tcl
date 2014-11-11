qc::trunc
=========

part of [Docs](.)

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

% set string &quot;This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.&quot;
This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.
% set string_varchar50 [qc::trunc $string 50]
This is a longer string than would be allowed in v
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"