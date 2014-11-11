qc::url_unset
=============

part of [Docs](.)

Usage
-----
`
        qc::url_unset url var_name
    `

Description
-----------
Unset a url encoded variable in url

Examples
--------
```tcl

&gt; qc::url_unset afile.html?foo=Hello&amp;bar=There bar
afile.html?foo=Hello
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"