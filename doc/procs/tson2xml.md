qc::tson2xml
============

part of [Docs](.)

Usage
-----
`qc::tson2xml tson`

Description
-----------


Examples
--------
```tcl

% set tson [list object Image  [list object  Width 800  Height 600  Title {View from the 15th Floor}  Thumbnail [list object  Url http://www.example.com/image/481989943  Height 125  Width [list string 100]]  IDs [list array 116 943 234 38793]]]
% qc::tson2xml $tson
&lt;Image&gt;&lt;Width&gt;800&lt;/Width&gt;
    &lt;Height&gt;600&lt;/Height&gt;
    &lt;Title&gt;View from the 15th Floor&lt;/Title&gt;
    &lt;Thumbnail&gt;&lt;Url&gt;http://www.example.com/image/481989943&lt;/Url&gt;
    &lt;Height&gt;125&lt;/Height&gt;
    &lt;Width&gt;100&lt;/Width&gt;&lt;/Thumbnail&gt;
    &lt;IDs&gt;&lt;item&gt;116&lt;/item&gt;&lt;item&gt;943&lt;/item&gt;&lt;item&gt;234&lt;/item&gt;&lt;item&gt;38793&lt;/item&gt;&lt;/IDs&gt;&lt;/Image&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"