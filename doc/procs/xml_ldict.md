qc::xml_ldict
=============

part of [Docs](../index.md)

Usage
-----
`
        qc::xml_ldict tag ldict
    `

Description
-----------
Create xml structure from a list of dicts.

Examples
--------
```tcl

% set data [list {product_code "AA" sales "9.99" qty 99} {product_code "BB" sales 0 qty 1000}]
{product_code "AA" sales "9.99" qty 99} {product_code "BB" sales 0 qty 1000}
% set xml "<records>[qc::xml_ldict record $data]</records>"
<records><record><product_code>AA</product_code>
<sales>9.99</sales>
<qty>99</qty></record><record><product_code>BB</product_code>
<sales>0</sales>
<qty>1000</qty></record></records>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"