qc::handlers call
==============

part of the [Handlers API](../handlers-api.md)

Usage
-----
`qc::handlers call path method`

Description
-----------
Call the registered handler that matches the given path and method.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::handlers call /home GET

% qc::handlers call / GET

% qc::handlers call /post POST
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"