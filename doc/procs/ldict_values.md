qc::ldict_values
================

part of [Docs](.)

Usage
-----
`
        qc::ldict_values ldictVar key
    `

Description
-----------
Return a list of the values of this key

Examples
--------
```tcl

% set dict_list [list {product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}]
{product widget_a sales 0} {product widget_b sales 99.99} {product widget_c sales 33}
%  qc::ldict_values dict_list product
widget_a widget_b widget_c
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"