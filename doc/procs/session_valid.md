qc::session_valid
===========

part of [Docs](../index.md)

Usage
-----
`session_valid args`

Description
-----------
Checks that the given session_id exists and has not expired.
Default age limit is 12 hours and default idle timeout is 1 hour. These can be specified with flags `-age_limit` and `-idle_timeout`.

Examples
--------
```tcl

% session_valid 27ade63f1ac52f82c3dc854b7e25a34389cc72fd
true

% session_valid -age_limit "24 hours" 27ade63f1ac52f82c3dc854b7e25a34389cc72fd
true

% session_valid -idle_timeout "30 mins" 27ade63f1ac52f82c3dc854b7e25a34389cc72fd
false

% session_valid -age_limit "24 hours" -idle_timeout "1 hour" 27ade63f1ac52f82c3dc854b7e25a34389cc72fd
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"