qc::escapeHTML
==============

part of [Docs](.)

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

% set text &quot;This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.&quot; 
This stuff is all true &#39;1&lt;2 &amp; 3&gt;2&#39;.
% set html &quot;&lt;html&gt;&lt;p&gt;[qc::escapeHTML $text]&lt;/p&gt;&lt;/html&gt;&quot;
&lt;html&gt;&lt;p&gt;This stuff is all true &amp;#39;1&amp;lt;2 &amp;amp; 3&amp;gt;2&amp;#39;.&lt;/p&gt;&lt;/html&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"