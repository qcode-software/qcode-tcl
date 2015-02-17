qc::response action redirect
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::response action redirect url`

Description
-----------
Sets the redirect element of the action object in the [global JSON response] with the given URL.

Examples
--------
```tcl

% qc::response action redirect "/post/74"
action {redirect {value {/post/74}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md