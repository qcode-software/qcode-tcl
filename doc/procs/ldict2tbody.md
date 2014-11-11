qc::ldict2tbody
===============

part of [Docs](.)

Usage
-----
`
        qc::ldict2tbody ldict colnames
    `

Description
-----------
Take a ldict and a list of col names to convert into tbody

Examples
--------
```tcl

set dict_list [list {code AAA product widget_a desc "Widget Type A" price 9.99 qty 10} {code BBB product widget_b desc "Widget Type B" price 8.99 qty 19} {code CCC product widget_c desc "Widget Type C" price 7.99 qty 1}]
{code AAA product widget_a desc "Widget Type A" price 9.99 qty 10} {code BBB product widget_b desc "Widget Type B" price 8.99 qty 19} {code CCC product widget_c desc "Widget Type C" price 7.99 qty 1}
% set tbody_cols [list product desc price]
product desc price
% set tbody [qc::ldict2tbody $dict_list $tbody_cols]
{widget_a {Widget Type A} 9.99} {widget_b {Widget Type B} 8.99} {widget_c {Widget Type C} 7.99}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"