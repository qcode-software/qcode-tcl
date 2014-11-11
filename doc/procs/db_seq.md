qc::db_seq
==========

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`qc::db_seq args`

Description
-----------
Fetch the next value from the sequence named seq_name

Examples
--------
```tcl

% db_dml {create sequence sales_order_no_seq}
% set sales_order_no [db_seq sales_order_no_seq]
% 1

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"