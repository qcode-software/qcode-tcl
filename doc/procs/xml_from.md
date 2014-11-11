qc::xml_from
============

part of [Docs](.)

Usage
-----
`
        qc::xml_from var ?var? ?var? ...
    `

Description
-----------
Return xml structure from the specified local variable names and values

Examples
--------
```tcl

% set name &quot;Angus Jamison&quot;
Angus Jamison
% set number &quot;01311111122&quot;
01311111122
% set xml &quot;&lt;record&gt;[qc::xml_from name number]&lt;/record&gt;&quot;
&lt;record&gt;&lt;name&gt;Angus Jamison&lt;/name&gt;
&lt;number&gt;01311111122&lt;/number&gt;&lt;/record&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"