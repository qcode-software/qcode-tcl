qc::sql_where_postcode
======================

part of [Docs](.)

Usage
-----
`qc::sql_where_postcode column postcode`

Description
-----------
Search for rows matching this full or partial UK postcode.

Examples
--------
```tcl

% qc::sql_where_postcode "delivery_postcode" "IV2 5DZ"
delivery_postcode ~ E'^IV2\\s5DZ$'
% qc::sql_where_postcode "delivery_postcode" "IV"
delivery_postcode ~ E'^IV[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$'
% qc::sql_where_postcode "delivery_postcode" "I"
delivery_postcode ~ E'^I[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$'
% qc::sql_where_postcode "delivery_postcode" ""
delivery_postcode ~ E'^[A-Z]{1,2}[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$'
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"