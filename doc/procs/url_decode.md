qc::url_decode
==============

part of [Docs](../index.md)

Usage
-----
`
        qc::url_decode string ?charset? 
    `

Description
-----------
Return url-decoded string with option to specify charset

Examples
--------
```tcl

> qc::url_decode "someplace.html%3forder_number%3d911%26title%3dca+s%c3%a1u"
someplace.html?order_number=911&title=ca sáu
> qc::url_decode "someplace.html%3forder_number%3d911%26title%3dca+s%e1u" iso8859-1
someplace.html?order_number=911&title=ca sáu
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"