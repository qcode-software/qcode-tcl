qc::multimap_get_all
====================

part of [Docs](.)

Usage
-----
`qc::multimap_get_all multimap key`

Description
-----------
Return all value for this key

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_get_all $multimap from
John Jill Gail
% 

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"