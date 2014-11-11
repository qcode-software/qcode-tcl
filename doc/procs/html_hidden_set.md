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
<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
<input type="hidden" name="order_key" value="66524F.kL" id="order_key">

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"