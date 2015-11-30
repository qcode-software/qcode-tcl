qc::path_best_match
==============

part of [Docs](../index.md)

Usage
-----
`qc::path_best_match path patterns`

Description
-----------
Finds the best match to path from the given patterns.

Examples
--------
```tcl
% qc::path_best_match /post/new [list /post /post/new /post/:post_id]
/post/new
% qc::path_best_match /post/75 [list /post /post/new /post/:post_id]
/post/:post_id
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"