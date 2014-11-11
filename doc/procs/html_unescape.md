qc::html_unescape
=================

part of [Docs](.)

Usage
-----
`qc::html_unescape text`

Description
-----------
Convert html entities back to text

Examples
--------
```tcl

% qc::html_unescape [qc::html_escape {Hello &lt;strong&gt;Brave&lt;/strong&gt; &amp; &quot;Wise&quot; Ones}]
Hello &lt;strong&gt;Brave&lt;/strong&gt; &amp; &quot;Wise&quot; Ones

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"