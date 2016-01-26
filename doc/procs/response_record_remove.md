qc::response record remove
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response record remove name`

Description
-----------
Removes an element from the record object of the [connection response](../connection-response.md) that matches the given name.

Examples
--------
```tcl

% qc::response record valid post_title "Hello World" ""
record {post_title {valid true value {Hello World} message {}}}

% qc::response record remove post_title
record {}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"