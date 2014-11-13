qc::url_to_html_hidden
======================

part of [Docs](../index.md)

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

> qc::url_to_html_hidden afile.html?foo=Hello&bar=There
<input type="hidden" name="foo" value="Hello" id="foo">
<input type="hidden" name="bar" value="There" id="bar">
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"