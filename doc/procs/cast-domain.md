qc::cast domain
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast domain name value`

Description
-----------
Cast $value to domain of $name.

Examples
--------
```tcl

% qc::cast domain post_state live
LIVE
% qc::cast domain foo bar
Can't cast "BAR": not a valid value for domain "foo".
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"