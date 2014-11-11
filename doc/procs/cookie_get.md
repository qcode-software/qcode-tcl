qc::cookie_get
==============

part of [Cookie Handling](../qc/wiki/CookiePage)

Usage
-----
`qc::cookie_get search_name`

Description
-----------
Get a cookie value or throw an error

Examples
--------
```tcl

% cookie_get session_id
12345654321
% 
% If the cookie cannot be found an error is thrown
% cookie_get foo
Cookie foo does not exist

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"