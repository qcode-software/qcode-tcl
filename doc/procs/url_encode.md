qc::url_encode
==============

part of [Docs](.)

Usage
-----
`
        qc::url_encode string ?charset? 
    `

Description
-----------
Return url-encoded string with option to specify charset

Examples
--------
```tcl

> qc::url_encode "someplace.html?order_number=911&title=ca sáu"
someplace.html%3forder_number%3d911%26title%3dca+s%c3%a1u
> qc::url_encode "someplace.html?order_number=911&title=ca sáu" iso8859-1
someplace.html%3forder_number%3d911%26title%3dca+s%e1u
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"