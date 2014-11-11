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

% qc::sql_where_postcode &quot;delivery_postcode&quot; &quot;IV2 5DZ&quot;
delivery_postcode ~ E&#39;^IV2\\s5DZ$&#39;
% qc::sql_where_postcode &quot;delivery_postcode&quot; &quot;IV&quot;
delivery_postcode ~ E&#39;^IV[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$&#39;
% qc::sql_where_postcode &quot;delivery_postcode&quot; &quot;I&quot;
delivery_postcode ~ E&#39;^I[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$&#39;
% qc::sql_where_postcode &quot;delivery_postcode&quot; &quot;&quot;
delivery_postcode ~ E&#39;^[A-Z]{1,2}[0-9][0-9]?[A-Z]?\\s[0-9][A-Z]{2}$&#39;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"