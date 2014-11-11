qc::form_var_exists
===================

part of [Docs](.)

Usage
-----
`qc::form_var_exists var_name`

Description
-----------
Test whether a form variable exists or not.

Examples
--------
```tcl

# some-page.html?foo=2&amp;foo=45&amp;bar=Hello%20World
% form_var_exists foo
1
% form_var_exists baz
0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"