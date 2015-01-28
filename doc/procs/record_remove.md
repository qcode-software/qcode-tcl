qc::record remove
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::record remove name`

Description
-----------
Removes an element from the record object of the [global JSON response] that matches the given name.

Examples
--------
```tcl

% qc::record valid post_title "Hello World" ""
record {post_title {valid true value {Hello World} message {}}}

% qc::record remove post_title
record {}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md