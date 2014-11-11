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

% set escaped_html "This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;."
This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.
% qc::unescapeHTML $escaped_html
This stuff is all true '1<2 & 3>2'.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"