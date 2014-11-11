qc::sql_array2list
==================

part of [Docs](../index.md)

Usage
-----
`qc::sql_array2list array`

Description
-----------


Examples
--------
```tcl

% db_1row {select array['John West','George East','Harry'] as list}
% set list
{"John West","George East",Harry}
%  qc::sql_array2list {"John West","George East",Harry}
{John West} {George East} Harry

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"