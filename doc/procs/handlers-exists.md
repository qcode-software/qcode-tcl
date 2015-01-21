qc::handlers exists
==============

part of [Docs](../index.md)

Usage
-----
`qc::handlers exists path method`

Description
-----------
Check if a request handler exists for the given path and method.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::exists /home GET
true

% qc::exists / GET
true

% qc::exists /foo POST
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"