qc::message notify
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::message notify message`

Description
-----------
Sets the notify element of the message object in the [global JSON response] with the given message.

Examples
--------
```tcl

% qc::message notify "An update is available."
message {notify {value {An update is available.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md