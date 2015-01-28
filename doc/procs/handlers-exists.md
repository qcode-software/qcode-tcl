qc::handlers exists
==============

part of the [Handlers API](../handlers-api.md)

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

% qc::handlers exists /home GET
true

% qc::handlers exists / GET
true

% qc::handlers exists /foo POST
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"