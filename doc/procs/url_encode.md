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

&gt; qc::url_encode &quot;someplace.html?order_number=911&amp;title=ca sáu&quot;
someplace.html%3forder_number%3d911%26title%3dca+s%c3%a1u
&gt; qc::url_encode &quot;someplace.html?order_number=911&amp;title=ca sáu&quot; iso8859-1
someplace.html%3forder_number%3d911%26title%3dca+s%e1u
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"