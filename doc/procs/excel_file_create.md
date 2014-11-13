qc::excel_file_create
=====================

part of [Docs](../index.md)

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
        "font-family" "Times New Roman"
        "font-size" "12"
        "color" "white"
        "font-weight" "bold"
        "font-style" "italic"
        "text-decoration" "underline"
        "text-align" "center"
        "vertical-align" "top"
        "background-color" "blue"
        "border" "2px solid red"
    }
    b {
        "border-bottom" "1px double blue"
        "text-decoration" "line-through"
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

ns_set update [ns_conn outputheaders] content-disposition "attachment; filename=test_spreadsheet.xls"
set mime_type "application/vnd.ms-excel"
ns_returnfile 200 $mime_type $filename
file delete $filename
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"