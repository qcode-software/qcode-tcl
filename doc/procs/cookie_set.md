qc::cookie_set
==============

part of [Cookie Handling](../cookie.md)

Usage
-----
`qc::cookie_set name value args`

Description
-----------
Set a cookie in outgoing headers for the current connection.

Optional named args:
* expires datetime
* max_age seconds
* domain url
* path path
* secure boolean

Examples
--------
```tcl

% cookie_set tracking Google expires "+30 days"
%
# delete a cookie
% cookie_set tracking "" expires yesterday

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
