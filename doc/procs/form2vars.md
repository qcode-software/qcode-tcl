qc::form2vars
=============

part of [Docs](../index.md)

Usage
-----
`
	form2vars ?varName? ?varName? ...
    `

Description
-----------
Create variables in the caller's namespace corresponding to the form data. If a list of variable names is specified then only create variables in that list if corresponding form data exists;otherwise create variables for all the names in the form data.
    <p>
    Where a form variable appears many times return values as list

Examples
--------
```tcl

# some-page.html?firstname=Jimmy&surname=Tarbuck
% form2vars firstname surname
% set firstname
Jimmy
% set surname
Tarbuck
%
# A repeated variable name will result in a list
# some-page.html?foo=1&foo=3&foo=56&bar=34
form2vars
# form2vars called with no args sets all form variables
set foo
1 3 56
set bar
34

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"