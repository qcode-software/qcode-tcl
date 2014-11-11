qc::ldict_max
=============

part of [Docs](.)

Usage
-----
`
        qc::ldict_max ldictVar key
    `

Description
-----------
Traverse a dict list and return the maximum of all dict values for given key.
         If non-numeric values are specified, the lexicographically greatest value is
         returned.

Examples
--------
```tcl

% set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
{product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
% qc::ldict_max dict_list sales
99.99
% qc::ldict_max dict_list product
widget_c
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"