qc::actions redirect
===========

part of [Docs](../index.md)

Usage
-----
`qc::actions redirect url'

Description
-----------
Sets the redirect element of the action object in the [global JSON response] with the given URL.

Examples
--------
```tcl

% qc::actions redirect "/post/74"
action {redirect {value {/post/74}}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md