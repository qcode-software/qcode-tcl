qc::response record all_valid
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response record all_valid'

Description
-----------
Checks the element in the record object of the [connection response](../connection-response.md) and returns true if the "valid" property of each element is true otherwise false.

Examples
--------
```tcl

% qc::response record invalid post_title "" "The title cannot be empty."
record {post_title {valid false value {} message {The title cannot be empty.}}}

% qc::response record all_valid
false

% qc::response record valid post_title "Hello World" ""
record {post_title {valid true value {Hello World} message {}}}

% qc::response record all_valid
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"