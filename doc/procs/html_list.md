qc::html_list
=============

part of [Docs](../index.md)

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
<ul>
<li>one</li>
<li>two</li>
<li>three</li>
<li>four</li>
</ul>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"