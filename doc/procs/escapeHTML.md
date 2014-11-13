qc::escapeHTML
==============

part of [Docs](../index.md)

Usage
-----
`
        qc::escapeHTML html
    `

Description
-----------
Convert reserved HTML characters in a string into entities.

Examples
--------
```tcl

% set text "This stuff is all true '1<2 & 3>2'." 
This stuff is all true '1<2 & 3>2'.
% set html "<html><p>[qc::escapeHTML $text]</p></html>"
<html><p>This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.</p></html>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"