qc::html
========

part of [Docs](../index.md)

Usage
-----
`qc::html tagName nodeValue args`

Description
-----------
Deprecated - use [qc::h] instead.
Generate an html node

Examples
--------
```tcl

% html span "Hello There"
<span>Hello There</span>
%
% html span "Hello There" class greeting
<span class="greeting">Hello There</span>
%
% html span "Hello There" class greeting value Escape&Me
<span class="greeting" value="Escape&amp;Me">Hello There</span>
%
% html span "Hello There" class greeting id oSpan value "don't \"quote\" me"
<span class="greeting" value="don't &#34;quote&#34; me">Hello There</span>
%
%  html span "Hello There" class greeting id oSpan value "don't \"quote\" me"
<span class="greeting" id="oSpan" value="don't &#34;quote&#34; me">Hello There</span>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::h]: h.md