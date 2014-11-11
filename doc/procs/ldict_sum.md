qc::ldict_sum
=============

part of [Docs](.)

Usage
-----
`
        qc::ldict_sum ldictVar key
    `

Description
-----------
Traverse a dict list and sum all dict values for given key.

Examples
--------
```tcl

1&gt; set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
{product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
2&gt; qc::ldict_sum dict_list sales
132.99
3&gt; qc::ldict_sum dict_list product
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"