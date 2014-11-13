qc::tson2xml
============

part of [Docs](../index.md)

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
<Image><Width>800</Width>
    <Height>600</Height>
    <Title>View from the 15th Floor</Title>
    <Thumbnail><Url>http://www.example.com/image/481989943</Url>
    <Height>125</Height>
    <Width>100</Width></Thumbnail>
    <IDs><item>116</item><item>943</item><item>234</item><item>38793</item></IDs></Image>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"