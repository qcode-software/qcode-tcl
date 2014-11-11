qc::url_decode
==============

part of [Docs](.)

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

&gt; qc::url_decode &quot;someplace.html%3forder_number%3d911%26title%3dca+s%c3%a1u&quot;
someplace.html?order_number=911&amp;title=ca sáu
&gt; qc::url_decode &quot;someplace.html%3forder_number%3d911%26title%3dca+s%e1u&quot; iso8859-1
someplace.html?order_number=911&amp;title=ca sáu
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"