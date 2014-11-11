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

% qc::url afile.html?foo=Goodbye foo &quot;Hello&quot; bar &quot;There&quot;
afile.html?foo=Hello&amp;bar=There
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"