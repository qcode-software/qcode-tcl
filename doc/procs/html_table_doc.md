qc::html_table_doc
==================

part of [Docs](.)

Usage
-----
`qc::html_table_doc args`

Description
-----------
Create a 2 row table with labels on the first row and values on the 2nd row.

Examples
--------
```tcl

% set cols {
    {label &quot;Sales Quote No.&quot; name sales_quote_no}
    {label &quot;Customer Order No.&quot; name customer_order_no}
}
% set sales_quote_no 12343
% set customer_order_no Tel/Bill
% qc::html_table_doc cols $cols class document
&lt;table class=&quot;document&quot;&gt;
&lt;colgroup&gt;
&lt;col name=&quot;sales_quote_no&quot;&gt;
&lt;col name=&quot;customer_order_no&quot;&gt;
&lt;/colgroup&gt;
&lt;thead&gt;
&lt;tr&gt;
&lt;th&gt;Sales Quote No.&lt;/th&gt;
&lt;th&gt;Customer Order No.&lt;/th&gt;
&lt;/tr&gt;
&lt;/thead&gt;
&lt;tbody&gt;
&lt;tr&gt;
&lt;td&gt;12343&lt;/td&gt;
&lt;td&gt;Tel/Bill&lt;/td&gt;
&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"