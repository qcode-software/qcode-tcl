qc::html
========

part of [Docs](.)

Usage
-----
`qc::html tagName nodeValue args`

Description
-----------
Generate an html node

Examples
--------
```tcl

% html span &quot;Hello There&quot;
&lt;span&gt;Hello There&lt;/span&gt;
%
% html span &quot;Hello There&quot; class greeting
&lt;span class=&quot;greeting&quot;&gt;Hello There&lt;/span&gt;
%
% html span &quot;Hello There&quot; class greeting value Escape&amp;Me
&lt;span class=&quot;greeting&quot; value=&quot;Escape&amp;amp;Me&quot;&gt;Hello There&lt;/span&gt;
%
% html span &quot;Hello There&quot; class greeting id oSpan value &quot;don&#39;t \&quot;quote\&quot; me&quot;
&lt;span class=&quot;greeting&quot; value=&quot;don&#39;t &amp;#34;quote&amp;#34; me&quot;&gt;Hello There&lt;/span&gt;
%
%  html span &quot;Hello There&quot; class greeting id oSpan value &quot;don&#39;t \&quot;quote\&quot; me&quot;
&lt;span class=&quot;greeting&quot; id=&quot;oSpan&quot; value=&quot;don&#39;t &amp;#34;quote&amp;#34; me&quot;&gt;Hello There&lt;/span&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"