# Copyright (C) 2001-2006, Bernhard van Woerden <bernhard@qcode.co.uk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /home/bernhard/cvs/exf/tcl/qc::xml.tcl,v 1.4 2003/03/27 11:26:23 nsadmin Exp $

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
    set string [ns_quotehtml $string]
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

doc xml2dict {
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


