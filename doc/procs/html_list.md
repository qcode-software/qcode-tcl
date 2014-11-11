qc::html_list
=============

part of [Docs](.)

Usage
-----
`qc::html_list list args`

Description
-----------
Convert list into HTML list.

Examples
--------
```tcl

% set list [list one two three four]
one two three four
% html_list $list
&lt;ul&gt;
&lt;li&gt;one&lt;/li&gt;
&lt;li&gt;two&lt;/li&gt;
&lt;li&gt;three&lt;/li&gt;
&lt;li&gt;four&lt;/li&gt;
&lt;/ul&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"