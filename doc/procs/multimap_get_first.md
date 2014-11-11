qc::multimap_get_first
======================

part of [Docs](.)

Usage
-----
`qc::multimap_get_first args`

Description
-----------
Return the value for the first matching key

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_get_first $multimap from
John
% qc::multimap_get_first -nocase $multimap FROM
John

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"