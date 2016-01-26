qc::response message alert
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response message alert message`

Description
-----------
Sets the alert element of the message object in the [connection response](../connection-response.md) with the given message.

Examples
--------
```tcl

% qc::response message alert "Incorrect username or password."
message {alert {value {Incorrect username or password.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"