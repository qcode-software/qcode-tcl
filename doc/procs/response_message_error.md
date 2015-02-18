qc::response message error
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::response message error message`

Description
-----------
Sets the error element of the message object in the [global JSON response] with the given message.

Examples
--------
```tcl

% qc::response message error "There was a problem processing part of your request. Please try again in a few moments."
message {error {value {There was a problem processing part of your request. Please try again in a few moments.}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md