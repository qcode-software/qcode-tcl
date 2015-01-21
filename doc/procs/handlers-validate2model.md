qc::handlers validate2model
==============

part of [Docs](../index.md)

Usage
-----
`qc::handlers validate2model path method`

Description
-----------
Validates the args of the handler registered for the given path and method. Returns true if all the data for the handler successfully validate otherwise false.

This will also set up the [JSON response](../global-json-response.md) with the outcome of validation.

See [Registration](../registration.md) for more information regarding request handlers.

Examples
--------
```tcl

% qc::handlers validate2model /post POST
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"