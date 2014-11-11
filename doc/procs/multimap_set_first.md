qc::multimap_set_first
======================

part of [Docs](.)

Usage
-----
`qc::multimap_set_first args`

Description
-----------
Set the value of the first matching key

Examples
--------
```tcl

% set multimap [list from John from Jill from Gail to Kim subject Hi]
from John from Jill from Gail to Kim subject Hi
% qc::multimap_set_first multimap from Johnny
from Johnny from Jill from Gail to Kim subject Hi
    % qc::multimap_set_first -nocase multimap FROM Johnny
from Johnny from Jill from Gail to Kim subject Hi

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"