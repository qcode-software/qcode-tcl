qc::cast domain
==============

part of [Cast API](../cast.md)

Usage
-----
`qc::cast domain domain_name value`

Description
-----------
Cast $value to domain of $domain_name.

Examples
--------
```tcl

% qc::cast domain plain_text Hello
Hello
% qc::cast domain plain_text "<div>Foo</div>"
Can't cast "<div>Foo</div>...": not a valid value for "plain_text".
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"