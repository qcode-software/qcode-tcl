qc::form2url
============

part of [Docs](.)

Usage
-----
`qc::form2url url`

Description
-----------
Encode the names and values of a form in an url

Examples
--------
```tcl

# some-page.html?foo=2&amp;foo=45&amp;bar=Hello%20World
form2url other-url.html
other-url.html?foo=2&amp;foo=45&amp;bar=Hello%20World

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"