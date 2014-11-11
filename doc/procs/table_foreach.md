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
    {Des O'Conner 123}
    {Bob Monkhouse 321}
}
% table_foreach $table {
    append html "<li>$firstname $surname $telephone</li>"
}
% set html 
<li>Jimmy Tarbuck 999</li><li>Des O'Conner 123</li><li>Bob Monkhouse 321</li>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"