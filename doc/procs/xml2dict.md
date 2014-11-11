qc::xml2dict
============

part of [Docs](.)

Usage
-----
`xml2dict $xml rootElement`

Description
-----------
Converts an XML structure in the form of a text string into a dict.
        Will start parsing from the element that matches the rootElement. 
        If nothing matches the root element an error will be thrown.

        Should only be used when the XML structure will not have repeating elements since it will only return the contents of one of the repeating elements.
        Does not look at attributes.

Examples
--------
```tcl

% set xml {
&lt;?xml version=&quot;1.0&quot;?&gt;
    &lt;messages&gt;
   &lt;note&gt;
        &lt;to&gt;Bill&lt;/to&gt;
        &lt;from&gt;Ben&lt;/from&gt;
        &lt;body&gt;Information&lt;/body&gt;
    &lt;/note&gt;
&lt;/messages&gt;
}

% xml2dict $xml messages
note {to Bill from Ben body Information}
% xml2dict $xml note
to Bill from Ben body Information
% xml2dict $xml dfgdfg
XML parse error
    

% set xml {
&lt;?xml version=&quot;1.0&quot;?&gt;
&lt;messages&gt;
    &lt;note&gt;
        &lt;to&gt;Bill&lt;/to&gt;
        &lt;from&gt;Ben&lt;/from&gt;
        &lt;body type=&quot;text&quot;&gt;Information&lt;/body&gt;
    &lt;/note&gt;
    &lt;note&gt;
        &lt;to&gt;Ben&lt;/to&gt;
        &lt;from&gt;Bill&lt;/from&gt;
        &lt;body&gt;What&lt;/body&gt;
    &lt;/note&gt;
&lt;/messages&gt;
}

% xml2dict $xml note
to Bill from Ben body Information
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"