qc::html_hidden
===============

part of [Docs](.)

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
&lt;input type=&quot;hidden&quot; name=&quot;customer_key&quot; value=&quot;As234454g.4/2&quot; id=&quot;customer_key&quot;&gt;
%
%  set order_key 66524F.kL
% html_hidden customer_key order_key
&lt;input type=&quot;hidden&quot; name=&quot;customer_key&quot; value=&quot;As234454g.4/2&quot; id=&quot;customer_key&quot;&gt;
&lt;input type=&quot;hidden&quot; name=&quot;order_key&quot; value=&quot;66524F.kL&quot; id=&quot;order_key&quot;&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"