qc::html_info_tables
====================

part of [Docs](.)

Usage
-----
`qc::html_info_tables args`

Description
-----------
Foreach dict in args return a table with 2 columns with name value in each row

Examples
--------
```tcl

% html_info_tables {Name &quot;Jimmy Tarbuck&quot; Venue &quot;Palace Ballroom&quot;} {Name &quot;Des O&#39;Conner&quot; Venue &quot;Royal Palladium&quot;}
&lt;table class=&quot;columns-container&quot;&gt;
&lt;tbody&gt;
&lt;tr&gt;
&lt;td&gt;&lt;table class=&quot;column&quot;&gt;
&lt;colgroup&gt;
&lt;col class=&quot;bold&quot;&gt;
&lt;col&gt;
&lt;/colgroup&gt;
&lt;tbody&gt;
&lt;tr&gt;
&lt;td&gt;Name&lt;/td&gt;
&lt;td&gt;Jimmy Tarbuck&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;Venue&lt;/td&gt;
&lt;td&gt;Palace Ballroom&lt;/td&gt;
&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;
&lt;/td&gt;
&lt;td&gt;&lt;table class=&quot;column&quot;&gt;
&lt;colgroup&gt;
&lt;col class=&quot;bold&quot;&gt;
&lt;col&gt;
&lt;/colgroup&gt;
&lt;tbody&gt;
&lt;tr&gt;
&lt;td&gt;Name&lt;/td&gt;
&lt;td&gt;Des O&#39;Conner&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;Venue&lt;/td&gt;
&lt;td&gt;Royal Palladium&lt;/td&gt;
&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;
&lt;/td&gt;
&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"