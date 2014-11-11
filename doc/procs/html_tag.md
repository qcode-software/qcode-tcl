qc::html_tag
============

part of [Docs](.)

Usage
-----
`qc::html_tag tagName args`

Description
-----------
Generate just the opening html tag

Examples
--------
```tcl

% html_tag input name firstname
&lt;input name=&quot;firstname&quot;&gt;
%
% html_tag input name firstname value &quot;Des O&#39;Conner&quot;
&lt;input name=&quot;firstname&quot; value=&quot;Des O&#39;Conner&quot;&gt;
%
% html_tag input name firstname value &quot;Des O&#39;Conner&quot; disabled yes
&lt;input name=&quot;firstname&quot; value=&quot;Des O&#39;Conner&quot; disabled&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"