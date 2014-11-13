qc::ldict_search
================

part of [Docs](../index.md)

Usage
-----
`
        qc::ldict_search ldictVar key value
    `

Description
-----------
Return the first index of the dict that contains the value $value for the key $key

Examples
--------
```tcl

% set dict_list [list {product widget_a stock_level 99} {product widget_b stock_level 8} {product widget_c stock_level 0}]
{product widget_a stock_level 99} {product widget_b stock_level 8} {product widget_c stock_level 0}
% qc::ldict_search dict_list stock_level 0
2
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"