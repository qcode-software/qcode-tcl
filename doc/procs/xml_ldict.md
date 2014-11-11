qc::xml_ldict
=============

part of [Docs](.)

Usage
-----
`
        qc::xml_ldict tag ldict
    `

Description
-----------
Create xml structure from a list of dicts.

Examples
--------
```tcl

% set data [list {product_code &quot;AA&quot; sales &quot;9.99&quot; qty 99} {product_code &quot;BB&quot; sales 0 qty 1000}]
{product_code &quot;AA&quot; sales &quot;9.99&quot; qty 99} {product_code &quot;BB&quot; sales 0 qty 1000}
% set xml &quot;&lt;records&gt;[qc::xml_ldict record $data]&lt;/records&gt;&quot;
&lt;records&gt;&lt;record&gt;&lt;product_code&gt;AA&lt;/product_code&gt;
&lt;sales&gt;9.99&lt;/sales&gt;
&lt;qty&gt;99&lt;/qty&gt;&lt;/record&gt;&lt;record&gt;&lt;product_code&gt;BB&lt;/product_code&gt;
&lt;sales&gt;0&lt;/sales&gt;
&lt;qty&gt;1000&lt;/qty&gt;&lt;/record&gt;&lt;/records&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"