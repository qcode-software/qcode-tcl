qc::safe_html_error_report
===========

part of [Safe HTML](../safe-html-markdown.md)

Usage
-----
`safe_html_error_report text`

Description
-----------
Checks the node and all of it's children for unsafe attributes and values.

Returns a list of dictionaries that specify unsafe items.

Each dictionary may have the following key value pairs:

Key | Value
|-------------|------
| `node_value` | the node that the error was found in
| `element` | the name of the element
| `reason` | the reason for the error
| `attribute` | the name of the attribute
| `attribute_value` | the attribute value

`node_value`, `element`, and `reason` will always be present in each dictionary.


Examples
--------
```tcl

% safe_html_error_report "<script>alert('Foo');</script>"
{node_value {<script>alert('Foo');</script>} element script reason {Unsafe element: script}}

% safe_html_error_report "<p foo=\"bar\">Foo</p>"
{node_value {<p foo="bar">Foo</p>} element p attribute foo reason {Unsafe attribute: foo}}

% safe_html_error_report "<a href=\"foo://bar.baz\""
{node_value {<a href="foo://bar.baz"></a>} element a attribute href attribute_value foo://bar.baz reason {Unsafe value "foo://bar.baz" for attribute "href"}}

% safe_html_error_report "<li>foo</li><thead>bar</thead>"
{node_value <li>foo</li> element li reason {List element without "<ul>" or "<ol>" ancestor}} {node_value <thead>bar</thead> element thead reason {Table element without "<table>" ancestor}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"