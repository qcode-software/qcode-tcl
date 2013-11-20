package provide qcode 2.01
package require doc
namespace eval qc {
    namespace export xml xml_* xml2dict
}

proc qc::xml { tagName nodeValue {dict_att ""} } {
    #| Constructs xml node from supplied parameters
    set latt {}
    foreach {name value} $dict_att {
	lappend latt "$name=\"[qc::xml_escape $value]\""
    }
    if { [llength $latt] > 0 } {
	return "<$tagName [join $latt]>[qc::xml_escape $nodeValue]</$tagName>"
    } else {
	return "<$tagName>[qc::xml_escape $nodeValue]</$tagName>"
    }
}

doc qc::xml {
    Description {
        Constructs xml from supplies parameters.
    }
    Usage {
        qc::xml tagName nodeValue ?{?attrib value? ?attrib value? ...}?
    }
    Examples {
        % qc::xml message "This is the message" [dict create messageType text]
        <message messageType="text">This is the message</message>
    }
}

proc qc::xml_escape { string } {
    #| Escape reserved characters and converts characters above 127 to entity decimal
    # Escape < > &
    set string [html_escape $string]
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $string {\\&} string
    # Escape characters with value at or above 127
    regsub -all -- {([\u007F-\u00FF])} $string {[qc::xml_encode_char \1]} string
    
    return [subst $string]
}

doc qc::xml_escape {
    Description {
        Escape reserved characters and converts characters above 127 to entity decimal
    }
    Usage {
        qc::xml_escape string
    }
    Examples {
        % qc::xml_escape "Special characters like \u009F and reserved characters like < > and & are escaped"
        Special characters like &#159; and reserved characters like &lt; &gt; and &amp; are escaped
    }
}

proc qc::xml_encode_char {string} {scan $string %c t; return "&#$t\;"}

doc qc::xml_encode_char {
    Description {
        Convert character to entity decimal format.
    }
    Usage {
        qc::xml_encode_char string
    }
    Examples {
        % qc::xml_encode_char a
        &#97;
        % qc::xml_encode_char \u009F
        &#159;
        % qc::xml_encode_char !
        &#33;
    }
}

proc qc::xml_decode_char_NNN {string} {
    #| Convert entity decimal format to ascii character
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $string {\\&} string
    regsub -all {&\#(\d{1,3});?} $string {[format %c [scan \1 %d tmp;set tmp]]} string
    return [subst $string]
}

doc qc::xml_decode_char_NNN {
    Description {
        Convert entity decimal format to ascii character
    }
    Usage {
        qc::xml_decode_char_NNN string
    }
    Examples {
       % qc::xml_decode_char_NNN "&#167; and &#166; are special characters."
        § and ¦ are special characters.
    }
}

proc qc::xml_from { args } {
    #| Return xml structure from the specified local variable names and values
    set list {}
    foreach name $args {
	upvar 1 $name value
	if { [info exists value] } {
	    lappend xml [qc::xml $name $value]
	} else {
	    error "Can't create xml with $name: No such variable"
	}
    }
    return [join $xml \n]
}

doc qc::xml_from {
    Description {
        Return xml structure from the specified local variable names and values
    }
    Usage {
        qc::xml_from var ?var? ?var? ...
    }
    Examples {
        % set name "Angus Jamison"
        Angus Jamison
        % set number "01311111122"
        01311111122
        % set xml "<record>[qc::xml_from name number]</record>"
        <record><name>Angus Jamison</name>
        <number>01311111122</number></record>
    }
}

proc qc::xml_ldict { li_tag ldict } {
    #| Create xml structure from a list of dicts
    set xml ""
    foreach dict $ldict {
	append xml "<$li_tag>[qc::dict2xml $dict]</$li_tag>"
    }
    return $xml
}

doc qc::xml_ldict {
    Description {
        Create xml structure from a list of dicts.
    }
    Usage {
        qc::xml_ldict tag ldict
    }
    Examples {
        % set data [list {product_code "AA" sales "9.99" qty 99} {product_code "BB" sales 0 qty 1000}]
        {product_code "AA" sales "9.99" qty 99} {product_code "BB" sales 0 qty 1000}
        % set xml "<records>[qc::xml_ldict record $data]</records>"
        <records><record><product_code>AA</product_code>
        <sales>9.99</sales>
        <qty>99</qty></record><record><product_code>BB</product_code>
        <sales>0</sales>
        <qty>1000</qty></record></records>
    }
}

proc qc::xml2dict { xml root_element } {
    #| Converts an XML structure in the form of a text string into a dict.
    set dict ""
    package require tdom
    dom parse $xml doc
    set subtree [$doc getElementsByTagName $root_element]
    if { $subtree eq "" } {
        error "XML parse error"
    } else {
        set node [lindex $subtree 0]
        set nodes [$node childNodes]
        foreach node $nodes {
            if { [llength [$node childNodes]] > 1 \
               || ([llength [$node childNodes]] == 1 \
                  && [ne [[$node firstChild] nodeType] TEXT_NODE] ) } {
                lappend dict [$node nodeName] [xml2dict $xml [$node nodeName]]
            }  elseif { [llength [$node childNodes]] == 0 } {
                # empty node
                lappend dict [$node nodeName] {}
            } else {
                lappend dict [$node nodeName] [$node asText]
            }
        }
    }
    return $dict
}

doc qc::xml2dict {
    Description {
        Converts an XML structure in the form of a text string into a dict.
        Will start parsing from the element that matches the rootElement. 
        If nothing matches the root element an error will be thrown.

        Should only be used when the XML structure will not have repeating elements since it will only return the contents of one of the repeating elements.
        Does not look at attributes.
    }
    Usage {xml2dict $xml rootElement}
    Examples {
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
    }
}

proc qc::xml_encoding {xml} {
    #| Return the TCL encoding scheme used for an xml document.
    # Try to determine encoding from the encoding attribute in the xml declaration.
    # Otherwise return default encoding "utf-8".
    set regexp1 {^[^>]+encoding=\"([^\"]*)\"}
    set regexp2 {^[^>]+encoding='([^']*)'}

    if { [regexp -nocase -expanded $regexp1 $xml -> encoding] || [regexp -nocase -expanded $regexp2 $xml -> encoding] } {
	return [IANAEncoding2TclEncoding [string trim $encoding]]
    } else {
	return utf-8
    }
}

doc qc::xml_encoding {
    Description {
        Return the TCL encoding scheme used for an xml document.
    }
    Usage {
        qc::xml_encoding xml
    }
    Examples {
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
    
    }
}
