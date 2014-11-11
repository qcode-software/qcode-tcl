qc::dict_sort
=============

part of [Docs](.)

Usage
-----
`qc::dict_sort dictVariable`

Description
-----------
Sort the top level dict contained in dictVariable by ascending key values.<br/>Write the resulting dict back to dictVariable and return the sorted dict.

Examples
--------
```tcl

% set dict {a 1 b 3 c 2}
a 1 b 3 c 2

% qc::dict_sort dict
a 1 c 2 b 3

% set dict
a 1 c 2 b 3

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"