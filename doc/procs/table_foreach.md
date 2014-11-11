qc::table_foreach
=================

part of [Docs](.)

Usage
-----
`table_foreach table code`

Description
-----------
Loop through the <proc>table</proc> row-by-row. Use local variables with names corresponding to the column names in the table to hold the data for each row. Execute the code given for every data row.

Examples
--------
```tcl

% set table {
    {firstname surname telephone}
    {Jimmy Tarbuck 999}
    {Des O&#39;Conner 123}
    {Bob Monkhouse 321}
}
% table_foreach $table {
    append html &quot;&lt;li&gt;$firstname $surname $telephone&lt;/li&gt;&quot;
}
% set html 
&lt;li&gt;Jimmy Tarbuck 999&lt;/li&gt;&lt;li&gt;Des O&#39;Conner 123&lt;/li&gt;&lt;li&gt;Bob Monkhouse 321&lt;/li&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"