qc::multimap_unset_first
========================

part of [Docs](../index.md)

Usage
-----
`qc::multimap_unset_first multimapVariable key args`

Description
-----------
Delete the first matching key/value pair from the multimap

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_unset_first multimap from
from Jill from Gail to Kim subject Hi

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"