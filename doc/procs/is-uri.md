qc::is uri
==========

part of [Is API](../is.md)

Usage
-----
`qc::is uri uri`

Description
-----------
Test if the given uri is valid according to rfc3986 (https://tools.ietf.org/html/rfc3986)

Examples
--------
```tcl

% qc::is uri www.google.com
1
% qc::is uri http://www.google.co.uk
1
% qc::is uri https://www.google.co.uk:443/subdir?formvar1=foo&formvar2=bar#anchor 
1
% qc::is uri /subdir?formvar1=foo&formvar2=bar#anchor 
1
% qc::is uri "http://test.co$%^&m"
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"