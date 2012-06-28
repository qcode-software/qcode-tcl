package provide qcode 1.5
package require doc
namespace eval qc {}

proc qc::xml { tagName nodeValue {dict_att ""} } {
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

proc qc::xml_escape { string } {
    # 
    # Escape < > &
    set string [html_escape $string]
    # Escape characters with value at or above 127
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $string {\\&} string

    regsub -all -- {([\u007F-\u00FF])} $string {[qc::xml_encode_char \1]} string
    
    return [subst $string]
}

proc qc::xml_encode_char {string} {scan $string %c t; return "&#$t\;"}

proc qc::xml_decode_char_NNN {string} {
    # e.g &#163 -> pound sign
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $string {\\&} string
    regsub -all {&\#(\d{1,3});?} $string {[format %c [scan \1 %d tmp;set tmp]]} string
    return [subst $string]
}

proc qc::xml_from { args } {
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

proc qc::xml_ldict { li_tag ldict } {
    set xml ""
    foreach dict $ldict {
	append xml "<$li_tag>[qc::dict2xml $dict]</$li_tag>"
    }
    return $xml
}

proc qc::xml2dict { xml root_element } {

    set dict ""
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
