qc::tson2json
=============

part of [Docs](../index.md)

Usage
-----
`qc::tson2json tson`

Description
-----------
Convert tson to json

Examples
--------
```tcl

% set tson [list object Image \
		    [list object \
		     Width [list number 800] \
		     Height 600 \
		     Title {View from the 15th Floor} \
		     Thumbnail [list object \
				Url http://www.example.com/image/481989943 \
				Height 125 \
				Width [list string 100]] \
		     IDs [list array 116 943 234 38793] \
                     TAGs [list array [list string 116] [list string 943]] \
                     Color null \
                     Count NAN \
                     ProductImage true \
                     CategoryImage [list boolean false]]]

% tson2json $tson
```
```json
{
    "Image": {
	"Width": 800,
	"Height": 600,
	"Title": "View from the 15th Floor",
	"Thumbnail": {
	    "Url": "http://www.example.com/image/481989943",
	    "Height": 125,
	    "Width": "100"
	},
	"IDs": [116,943,234,38793],
	"TAGs": ["116","943"],
	"Color": null,
	"Count": "NAN",
	"ProductImage": true,
	"CategoryImage": false
    }
}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
