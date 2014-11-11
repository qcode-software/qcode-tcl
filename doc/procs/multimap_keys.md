qc::multimap_keys
=================

part of [Docs](../index.md)

Usage
-----
`qc::multimap_keys multimap`

Description
-----------
Return a list of keys in the multimap

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_keys $multimap
from from from to subject

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"