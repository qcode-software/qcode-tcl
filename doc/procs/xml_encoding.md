qc::xml_encoding
================

part of [Docs](.)

Usage
-----
`
        qc::xml_encoding xml
    `

Description
-----------
Return the TCL encoding scheme used for an xml document.

Examples
--------
```tcl

% set xml {
&lt;?xml version=&quot;1.0&quot; encoding=&quot;windows-1252&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;
}

&lt;?xml version=&quot;1.0&quot; encoding=&quot;windows-1252&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;
    
% qc::xml_encoding $xml
cp1252

% set xml {
&lt;?xml version=&quot;1.0&quot; encoding=&quot;ISO-8859-1&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;
}
    
&lt;?xml version=&quot;1.0&quot; encoding=&quot;ISO-8859-1&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;

% qc::xml_encoding $xml
iso8859-1

% set xml {
&lt;?xml version=&quot;1.0&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;
}

&lt;?xml version=&quot;1.0&quot;?&gt;
&lt;record&gt;
&lt;name&gt;Angus&lt;/name&gt;
&lt;/record&gt;
    
% qc::xml_encoding $xml
utf-8
    
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"