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
<?xml version="1.0"?>
    <messages>
   <note>
        <to>Bill</to>
        <from>Ben</from>
        <body>Information</body>
    </note>
</messages>
}

% xml2dict $xml messages
note {to Bill from Ben body Information}
% xml2dict $xml note
to Bill from Ben body Information
% xml2dict $xml dfgdfg
XML parse error
    

% set xml {
<?xml version="1.0"?>
<messages>
    <note>
        <to>Bill</to>
        <from>Ben</from>
        <body type="text">Information</body>
    </note>
    <note>
        <to>Ben</to>
        <from>Bill</from>
        <body>What</body>
    </note>
</messages>
}

% xml2dict $xml note
to Bill from Ben body Information
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"