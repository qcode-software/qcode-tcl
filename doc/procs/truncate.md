qc::truncate
============

part of [Docs](.)

Usage
-----
`
        qc::truncate string length
    `

Description
-----------
Truncate to nearest word boundary to create string of at the most of specified length

Examples
--------
```tcl

% set string &quot;This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.&quot;
This is a longer string than would be allowed in varchar(50) DB columns so use trunc to truncate appropriately.
set string_varchar50 [qc::truncate  $string 50]
This is a longer string than would be allowed in 
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"