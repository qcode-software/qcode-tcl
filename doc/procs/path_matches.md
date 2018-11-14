qc::path_matches
==============

part of [Docs](../index.md)

Usage
-----
`qc::path_matches path patterns`

Description
-----------
Checks if the given path matches any of the given patterns.

Examples
--------
```tcl
% qc::path_matches /home [list /foo /bar /baz /home]
true
% qc::path_matches /home [list /foo /bar /baz /hom]
false
% qc::path_matches /foo/75 [list /foo /bar /baz /foo/:foo_id]
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"