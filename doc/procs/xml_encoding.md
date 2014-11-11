qc::xml_encoding
================

part of [Docs](../index.md)

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
<?xml version="1.0" encoding="windows-1252"?>
<record>
<name>Angus</name>
</record>
}

<?xml version="1.0" encoding="windows-1252"?>
<record>
<name>Angus</name>
</record>
    
% qc::xml_encoding $xml
cp1252

% set xml {
<?xml version="1.0" encoding="ISO-8859-1"?>
<record>
<name>Angus</name>
</record>
}
    
<?xml version="1.0" encoding="ISO-8859-1"?>
<record>
<name>Angus</name>
</record>

% qc::xml_encoding $xml
iso8859-1

% set xml {
<?xml version="1.0"?>
<record>
<name>Angus</name>
</record>
}

<?xml version="1.0"?>
<record>
<name>Angus</name>
</record>
    
% qc::xml_encoding $xml
utf-8
    
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"