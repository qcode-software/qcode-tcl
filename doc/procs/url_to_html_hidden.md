qc::url_to_html_hidden
======================

part of [Docs](.)

Usage
-----
`
        qc::url_to_html_hidden url
    `

Description
-----------
Convert a url with form vars into html hidden input tags.<br>

Examples
--------
```tcl

&gt; qc::url_to_html_hidden afile.html?foo=Hello&amp;bar=There
&lt;input type=&quot;hidden&quot; name=&quot;foo&quot; value=&quot;Hello&quot; id=&quot;foo&quot;&gt;
&lt;input type=&quot;hidden&quot; name=&quot;bar&quot; value=&quot;There&quot; id=&quot;bar&quot;&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"