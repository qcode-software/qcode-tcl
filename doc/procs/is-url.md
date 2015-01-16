qc::is url
==========

part of [Docs](../index.md)

Usage
-----
`qc::is url args`

Description
-----------
Checks if the given string is a URL.
This is a more restrictive subset of all legal uri's defined by RFC 3986.

Examples
--------
```tcl

% qc::is url www.google.com
0
% qc::is url http://www.google.co.uk
1
% qc::is url https://www.google.co.uk:443/subdir?formvar1=foo&formvar2=bar#anchor 
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
