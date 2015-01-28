qc::is safe_html
==============

part of [Is API](../is.md)

Usage
-----
`qc::is safe_html string`

Description
-----------
Checks if the given string containts only safe HTML elements and attributes.

See [Safe HTML] for more information regarding safe elements, attributes, and values.

Examples
--------
```tcl

% qc::is safe_html {<foo>bar</foo>}
0
% qc::is safe_html {<img src="http://link.to.image" />}
1
% qc::is safe_html {It doesn't have to be just HTML. There can be content that might include HTML <pre><code class="language-tcl">puts Hello World</code></pre>}
1
% qc::is safe_html {<div id="content">Foo</div>}
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Safe HTML]: ../safe_html.md