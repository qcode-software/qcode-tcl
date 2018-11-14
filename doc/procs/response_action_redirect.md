qc::response action redirect
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response action redirect url`

Description
-----------
Sets the redirect element of the action object in the [connection response](../connection-response.md) with the given URL.

Examples
--------
```tcl

% qc::response action redirect "/post/74"
action {redirect {value {/post/74}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"