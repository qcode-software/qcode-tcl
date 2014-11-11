qc::html_hidden
===============

part of [Docs](../index.md)

Usage
-----
`qc::html_hidden args`

Description
-----------
Create hidden fields from vars

Examples
--------
```tcl

% set customer_key As234454g.4/2
% html_hidden customer_key
<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
%
%  set order_key 66524F.kL
% html_hidden customer_key order_key
<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
<input type="hidden" name="order_key" value="66524F.kL" id="order_key">

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"