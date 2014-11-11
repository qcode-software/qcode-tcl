qc::html_menu
=============

part of [Docs](.)

Usage
-----
`qc::html_menu lmenu`

Description
-----------
Join items to form a horizontal menu

Examples
--------
```tcl

% html_menu [list [html_a Sales sales.html] [html_a Purchasing sales.html] [html_a Accounts sales.html]]
    &lt;a href=&quot;sales.html&quot;&gt;Sales&lt;/a&gt; &amp;nbsp;&lt;b&gt;|&lt;/b&gt;&amp;nbsp; &lt;a href=&quot;sales.html&quot;&gt;Purchasing&lt;/a&gt; &amp;nbsp;&lt;b&gt;|&lt;/b&gt;&amp;nbsp; &lt;a href=&quot;sales.html&quot;&gt;Accounts&lt;/a&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"