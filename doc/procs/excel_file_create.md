qc::excel_file_create
=====================

part of [Docs](.)

Usage
-----
`qc::excel_file_create args`

Description
-----------
Creates an xls file using the information provided

Examples
--------
```tcl

set data {
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
    {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
}
set formats {
    a {
        &quot;font-family&quot; &quot;Times New Roman&quot;
        &quot;font-size&quot; &quot;12&quot;
        &quot;color&quot; &quot;white&quot;
        &quot;font-weight&quot; &quot;bold&quot;
        &quot;font-style&quot; &quot;italic&quot;
        &quot;text-decoration&quot; &quot;underline&quot;
        &quot;text-align&quot; &quot;center&quot;
        &quot;vertical-align&quot; &quot;top&quot;
        &quot;background-color&quot; &quot;blue&quot;
        &quot;border&quot; &quot;2px solid red&quot;
    }
    b {
        &quot;border-bottom&quot; &quot;1px double blue&quot;
        &quot;text-decoration&quot; &quot;line-through&quot;
    }
}
set column_meta {
    2 {class a}
    3 {class b width 60 type string}
    12 {width 30}
}
set row_meta {
    3 {height 40 class b}
}
set cell_meta {
    {0 0} {type string}
    {3 7} {class a}
}

set filename [qc::excel_file_create ~ data formats column_meta row_meta cell_meta]

ns_set update [ns_conn outputheaders] content-disposition &quot;attachment; filename=test_spreadsheet.xls&quot;
set mime_type &quot;application/vnd.ms-excel&quot;
ns_returnfile 200 $mime_type $filename
file delete $filename
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"