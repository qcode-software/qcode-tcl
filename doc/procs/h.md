qc::h
========

part of [Docs](../index.md)

Usage
-----
`qc::h tag_name args`

Description
-----------
Generate an html node.

Examples
--------
```tcl

% h span "Hello There"
<span>Hello There</span>
%
% h span class greeting "Hello There"
<span class="greeting">Hello There</span>
%
% h span class greeting value Escape&Me "Hello There"
<span class="greeting" value="Escape&amp;Me">Hello There</span>
%
% h span class greeting id oSpan value "don't \"quote\" me" "Hello There"
<span class="greeting" value="don't &#34;quote&#34; me">Hello There</span>
%
% h span class greeting id oSpan value "don't \"quote\" me" "Hello There"
<span class="greeting" id="oSpan" value="don't &#34;quote&#34; me">Hello There</span>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"