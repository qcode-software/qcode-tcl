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
    {label "Sales Quote No." name sales_quote_no}
    {label "Customer Order No." name customer_order_no}
}
% set sales_quote_no 12343
% set customer_order_no Tel/Bill
% qc::html_table_doc cols $cols class document
<table class="document">
<colgroup>
<col name="sales_quote_no">
<col name="customer_order_no">
</colgroup>
<thead>
<tr>
<th>Sales Quote No.</th>
<th>Customer Order No.</th>
</tr>
</thead>
<tbody>
<tr>
<td>12343</td>
<td>Tel/Bill</td>
</tr>
</tbody>
</table>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"