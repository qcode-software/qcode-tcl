qc::is domain
==============

part of [Is API](../is.md)

Usage
-----
`qc::is domain domain_name value`

Description
-----------
Checks if the given value follows the constraints of the given domain in the database.

Examples
--------
```tcl

% qc::is domain plain_text "Hello World"
1
% qc::is domain plain_text "<div>Foo</div>"
0
% qc::is domain foo bar 
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"