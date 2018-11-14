qc::response record sensitive
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response record sensitive name`

Description
-----------
Marks an item that matches the given name in the record object of the [connection response](../connection-response.md) as sensitive.

The value of a sensitive record item will not be returned in the response.

Examples
--------
```tcl

% qc::response record sensitive password
record {password {valid true value {Hello World} message {} sensitive true}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"