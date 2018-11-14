qc::path_variables
==============

part of [Docs](../index.md)

Usage
-----
`qc::path_variables path pattern`

Description
-----------
Gets variables from the path that corresponds to colon variables in the pattern.

Examples
--------
```tcl
% qc::path_variables /post/75 /post/:post_id
post_id new
% qc::path_variables /post/31/comment/41 /post/:post_id/comment/:comment_id
post_id 31 comment_id 41
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"