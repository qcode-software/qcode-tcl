qc::handlers exists
==============

part of the [Handlers API](../handlers-api.md)

Usage
-----
`qc::handlers exists method path`

Description
-----------
Check if a request handler exists for the given path and method.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::handlers exists GET /home
true

% qc::handlers exists GET /
true

% qc::handlers exists POST /foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"