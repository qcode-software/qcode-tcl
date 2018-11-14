qc::response message error
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response message error message`

Description
-----------
Sets the error element of the message object in the [connection response](../connection-response.md) with the given message.

Examples
--------
```tcl

% qc::response message error "There was a problem processing part of your request. Please try again in a few moments."
message {error {value {There was a problem processing part of your request. Please try again in a few moments.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"