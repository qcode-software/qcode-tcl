qc::form_var_get
================

part of [Docs](.)

Usage
-----
`qc::form_var_get var_name`

Description
-----------
If the form variable exists return its value otherwise throw an error.<br/>A repeated form variable will return a list of corresponding values.<br/>PHP style repeated form variables foo[]=1 foo[]=2 treated as a list.

Examples
--------
```tcl

# some-page.html?foo=2&foo=45&bar=Hello%20World
% form_var_get foo
2 45
% form_var_get bar
Hello World
%
% form_var baz
No such form variable "baz"
%
# some-page.html?foo[]=a&foo[]=b
% form_var_get foo
a b

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"