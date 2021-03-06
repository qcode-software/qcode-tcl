qc::validate2model
===========

part of [Docs](../index.md)

Usage
-----
`validate2model dict`

Description
-----------
Validates a given dictionary against the data model and sets up the record in the connection response.

If the record type is `password` or `card_number` then it is automatically marked as sensitive and the value will not appear in the response.

Returns true if all the data is valid otherwise false.

Examples
--------
```tcl

% dict set example firstname Foo
% dict set example surname Bar

% validate2model $example
true

% set data
record {firstname {valid true value Foo message {}} surname {valid true value Bar message {}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"