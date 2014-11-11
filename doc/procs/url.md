qc::url
=======

part of [Docs](.)

Usage
-----
`
        qc::url url ?var value? ...
    `

Description
-----------
Take an url with or without url encoded vars and insert or replace vars based on<br> 
        the supplied pairs of var & value.

Examples
--------
```tcl

% qc::url afile.html?foo=Goodbye foo "Hello" bar "There"
afile.html?foo=Hello&bar=There
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"