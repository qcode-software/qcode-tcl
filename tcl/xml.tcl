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

proc qc::xml_encode_char {string} {scan $string %c t; return "&#$t\;"}

proc qc::xml_decode_char_NNN {string} {
    #| Convert entity decimal format to ascii character
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $string {\\&} string
    regsub -all {&\#(\d{1,3});?} $string {[format %c [scan \1 %d tmp;set tmp]]} string
    return [subst $string]
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

proc qc::xml_ldict { li_tag ldict } {
    #| Create xml structure from a list of dicts
    set xml ""
    foreach dict $ldict {
	append xml "<$li_tag>[qc::dict2xml $dict]</$li_tag>"
    }
    return $xml
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

proc qc::xml_declaration_valid {declaration} {
    #| Determines if the given XML declaration is valid.

    set pattern {^<\?xml\s+}
    append pattern {version\s*=\s*("1\.[0-9]+"|'1\.[0-9]+')}
    set encoding_value {[a-zA-Z]([a-zA-Z0-9.-_]|-)*}
    append pattern [subst {(\\s+encoding\\s*=\\s*("$encoding_value"|'$encoding_value'))?}]
    append pattern {(\s+standalone\s*=\s*("(yes|no)"|'(yes|no)'))?}
    append pattern {\s*\?>}

    return [regexp $pattern $declaration]
}
