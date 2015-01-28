qc::handlers validate2model
==============

part of the [Handlers API](../handlers-api.md)

Usage
-----
`qc::handlers validate2model method path`

Description
-----------
Validates the args of the handler registered that is identified by the given method and path. Returns true if all the data for the handler successfully validate otherwise false.

This will also set up the [JSON response](../global-json-response.md) with the outcome of validation.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::handlers validate2model POST /post
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"