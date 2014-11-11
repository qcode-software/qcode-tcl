qc::url_back
============

part of [Docs](.)

Usage
-----
`
        qc::url_back url args
    `

Description
-----------
Creates a link to url with a formvar next_url which links back to the current page.<br>
        Preserve vars passed in via GET or POST

Examples
--------
```tcl

set order_number 911
set html [html_a &quot;Do something to order $order_number and return&quot; [url_back destination.html order_number]] 
&lt;a href=&quot;destination.html?order_number=911&amp;amp;next_url=https%3a%2f%2fwww.domain.co.uk%2fsource.html%3forder_number%3d911&quot;&gt;Do something to order 911 and return&lt;/a&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"