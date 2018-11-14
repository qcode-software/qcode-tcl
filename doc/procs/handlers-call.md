qc::handlers call
==============

part of the [Handlers API](../handlers-api.md)

Usage
-----
`qc::handlers call method path`

Description
-----------
Call the registered handler that is identified by the given method and path.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::handlers call GET /home

% qc::handlers call GET /

% qc::handlers call POST /post
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"