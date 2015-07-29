qc::url
=======

part of [Docs](../index.md)

Usage
-----
`qc::url url ?name value? ...`

Description
-----------
 Builds a URL from a given base and name value pairs.
 Substitutes and encodes any colon variables from the name value pairs into the path and fragment with any remaining name value pairs treated as parameters for the query string.
 NOTE: Only supports root-relative URLs.

Examples
--------
```tcl

% qc::url afile.html?foo=Goodbye foo "Hello" bar "There"
/afile.html?foo=Hello&bar=There

% qc::url /:foo/:bar foo 123 bar 456
/123/456

% qc::url /:foo/:bar foo 123 bar 456 baz 789
/123/456?baz=789

% qc::url /path?foo=abc#:fragment foo 123 fragment title
/path?foo=123#title
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"