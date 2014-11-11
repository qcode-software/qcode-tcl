qc::html_a_replace
==================

part of [Docs](.)

Usage
-----
`qc::html_a_replace link url args`

Description
-----------


Examples
--------
```tcl

% html_a_replace Google http://www.google.co.uk 
&lt;a href=&quot;http://www.google.co.uk&quot; onclick=&quot;location.replace(this.href);return false;&quot;&gt;Google&lt;/a&gt;
%
% html_a_replace Google http://www.google.co.uk title &quot;Google Search&quot; class highlight
    &lt;a title=&quot;Google Search&quot; class=&quot;highlight&quot; href=&quot;http://www.google.co.uk&quot; onclick=&quot;location.replace(this.href);return false;&quot;&gt;Google&lt;/a&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"