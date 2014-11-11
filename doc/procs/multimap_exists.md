qc::multimap_exists
===================

part of [Docs](../index.md)

Usage
-----
`qc::multimap_exists multimap key`

Description
-----------
Check if a value exists for this key

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_exists $multimap subject
1
% qc::multimap_exists $multimap foo
0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"