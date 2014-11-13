qc::is_url
==========

part of [Docs](../index.md)

Usage
-----
`qc::is_url args`

Description
-----------
This is a more restrictive subset of all legal uri's defined by RFC 3986<br/>Relax as needed

Examples
--------
```tcl

% qc::is_url www.google.com
0
% qc::is_url http://www.google.co.uk
1
% qc::is_url https://www.google.co.uk:443/subdir?formvar1=foo&formvar2=bar#anchor 
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"