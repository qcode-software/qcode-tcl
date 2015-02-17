qc::response record valid
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::response record valid name value message`

Description
-----------
Adds or modifies a valid element in the record object of the [global JSON response].

The name argument is the name of the element.
The value argument is the value of the element.
The message argument is a message relating to the element. E.g. Mention if the value was converted or modified in some way.

Examples
--------
```tcl

% qc::response record valid post_title "Hello World" ""
record {post_title {valid true value {Hello World} message {}}}

% qc::response record valid post_title "Foo Bar" ""
record {post_title {valid true value {Foo Bar} message {}}}

% qc::response record valid post_title "Foo Bar" "The title was converted to proper case."
record {post_title {valid true value {Foo Bar} message {The title was converted to proper case.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md