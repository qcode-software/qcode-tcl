qc::unescapeHTML
================

part of [Docs](.)

Usage
-----
`
        qc::unescapeHTML html
    `

Description
-----------
Convert HTML entities back to their ascii characters.

Examples
--------
```tcl

% set escaped_html &quot;This stuff is all true &amp;#39;1&amp;lt;2 &amp;amp; 3&amp;gt;2&amp;#39;.&quot;
This stuff is all true &amp;#39;1&amp;lt;2 &amp;amp; 3&amp;gt;2&amp;#39;.
% qc::unescapeHTML $escaped_html
This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"