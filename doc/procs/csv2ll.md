qc::csv2ll
==========

part of [Docs](.)

Usage
-----
`qc::csv2ll csv`

Description
-----------
Convert csv data to a list of lists<br/>Accepts csv quoted fields separated by commas with records terminated by newlines.<br/>Commas and newlines may appear inside a quoted field.

Examples
--------
```tcl

    % set csv {&quot;one&quot;,&quot;two&quot;,&quot;three&quot;
4,5,6}
    % csv2ll $csv
    {one two three} {4 5 6}
    %
    set csv {,&quot;one
two&quot;,&quot;three&quot;&quot;,&quot;,&quot;,&quot;&quot;four&quot;,&quot;,&quot;
2,3,4,&quot;,
&quot;,9}
    % csv2ll $csv
    {{} {one
two} three\&quot;, ,\&quot;four ,} {2 3 4 {,
} 9}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"