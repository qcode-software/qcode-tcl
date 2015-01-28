qc::record all_valid
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::record all_valid'

Description
-----------
Checks the element in the record object of the [global JSON response] and returns true if the "valid" property of each element is true otherwise false.

Examples
--------
```tcl

% qc::record invalid post_title "" "The title cannot be empty."
record {post_title {valid false value {} message {The title cannot be empty.}}}

% qc::record all_valid
false

% qc::record valid post_title "Hello World" ""
record {post_title {valid true value {Hello World} message {}}}

% qc::record all_valid
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md