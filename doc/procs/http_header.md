qc::http_header
===============

part of [Docs](.)

Usage
-----
`qc::http_header name value`

Description
-----------
Return http header.<br/>Raise an error if the value of the http header contains newline characters.

Examples
--------
```tcl

% http_header Content-Type application/json
Content-Type: application/json
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"