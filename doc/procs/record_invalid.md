qc::record invalid
===========

part of [Docs](../index.md)

Usage
-----
`qc::record invalid name value message`

Description
-----------
Adds or modifies an invalid element in the record object of the [global JSON response].

The name argument is the name of the element.
The value argument is the value of the element.
The message argument is a message relating to the element. E.g. If or why the element was invalid.

Examples
--------
```tcl

% qc::record invalid post_title "" "The title cannot be empty."
record {post_title {valid false value {} message {The title cannot be empty.}}}

% qc::record invalid post_title "All Good Things Comes To Those Who Wait" "The title is too long. It should be a maximum of 30 characters."
record {post_title {valid false value {All Good Things Comes To Those Who Wait} message {The title is too long. It should be a maximum of 30 characters.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md