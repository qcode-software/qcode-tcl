qc::response message notify
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response message notify message`

Description
-----------
Sets the notify element of the message object in the [connection response](../connection-response.md) with the given message.

Examples
--------
```tcl

% qc::response message notify "An update is available."
message {notify {value {An update is available.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"