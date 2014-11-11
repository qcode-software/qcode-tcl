qc::html_hidden_set
===================

part of [Docs](.)

Usage
-----
`qc::html_hidden_set args`

Description
-----------
Create hidden fields from list of name value pairs.

Examples
--------
```tcl

% html_hidden_set customer_key As234454g.4/2 order_key 66524F.kL
&lt;input type=&quot;hidden&quot; name=&quot;customer_key&quot; value=&quot;As234454g.4/2&quot; id=&quot;customer_key&quot;&gt;
&lt;input type=&quot;hidden&quot; name=&quot;order_key&quot; value=&quot;66524F.kL&quot; id=&quot;order_key&quot;&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"