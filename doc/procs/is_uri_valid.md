qc::is_uri_valid
==========

part of [Docs](../index.md)

Usage
-----
`qc::is_uri_valid url`

Description
-----------
Deprecated - see [qc::is uri]
Test if the given uri is valid according to rfc3986 (https://tools.ietf.org/html/rfc3986)

Examples
--------
```tcl

% qc::is_uri_valid www.google.com
1
% qc::is_uri_valid http://www.google.co.uk
1
% qc::is_uri_valid https://www.google.co.uk:443/subdir?formvar1=foo&formvar2=bar#anchor 
1
% qc::is_uri_valid /subdir?formvar1=foo&formvar2=bar#anchor 
1
% qc::is_uri_valid "http://test.co$%^&m"
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is uri]: is-uri.md

