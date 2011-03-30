proc tson_object { args } {
    # return object tson from list of name value pairs in args by inserting object keyword at index 0 of list.
    # use appropriate keywords depending on value type. Cannot be used to create nested objects
    # EXAMPLE:  % tson_object firstname "Daniel" surname "Clark" age 23
    #           object firstname {string Daniel} surname {string Clark} age 23

    set tson [list object]
    
    foreach {name value} $args {
	if { [is_decimal $value] || [in {true false null} $value] } {
	    lappend tson $name $value
	} else { 
	    lappend tson $name [list string $value]
	}
    }

    return $tson
}

proc json_quote {value} {
    return "\"[string map {\" \\\" \\ \\\\ \n \\n \r \\r \f \\f \b \\b \t \\t} $value]\""
}

proc tson2json { tson } {
    switch -- [lindex $tson 0] {
	object {
	    set list {}
	    foreach {name value} [lrange $tson 1 end] {
		lappend list "[json_quote $name]: [tson2json $value]"
	    }
	    return "\{\n[join $list ",\n"]\n\}"
	}
	array {
	    set list {}
	    foreach value [lrange $tson 1 end] {
		lappend list [tson2json $value]
	    }
	    return "\[[join $list ,]\]"
	}
	string {
	    return [json_quote [lindex $tson 1]]
	}
	default {
	    if { [string is double -strict $tson] || [in {true false null} $tson]} {
		return $tson
	    } else {
		return [json_quote $tson]
	    }
	}
    }
}

doc tson2json {
    Examples {
	% set tson [list object Image \ 
		    [list object \ 
		     Width 800 \ 
		     Height 600 \ 
		     Title {View from the 15th Floor} \ 
		     Thumbnail [list object \ 
				Url http://www.example.com/image/481989943 \ 
				Height 125 \ 
				Width [list string 100]] \ 
		     IDs [list array 116 943 234 38793]]]

	% tson2json $tson
	{ 
	    "Image": {
		"Width": 800,
		"Height": 600,
		"Title": "View from the 15th Floor",
		"Thumbnail": {
		    "Url": "http://www.example.com/image/481989943",
		    "Height": 125,
		    "Width": "100"
		},
		"IDs": [116,943,234,38793]
	    }
	}
    }
}

proc qc::tson_object_from { args } {
    # Take a list of var names and return a tson object
    set dict {}
    foreach name $args {
	upvar 1 $name value
	if { [info exists value] } {
	    lappend dict $name $value
	} else {
	    error "Can't create dict with $name: No such variable"
	}
    }
    return [tson_object {*}$dict]
}

proc qc::tson2xml { tson } {
    # not dealt with attributes 
    # prefered technique
    # http://www.ibm.com/developerworks/xml/library/x-xml2jsonphp/
    
    switch -- [lindex $tson 0] {
	object {
	    set list {}
	    foreach {name value} [lrange $tson 1 end] {
		lappend list <$name>[tson2xml $value]</$name>
	    }
	    return [join $list "\n"]
	}
	array {
	    set list {}
	    foreach value [lrange $tson 1 end] {
		lappend list <item>[tson2xml $value]</item>
	    }
	    return [join $list ""]
	}
	string {
	    return [qc::xml_escape [lindex $tson 1]]
	}
	default {
	    if { [string is double -strict $tson] || [in {true false null} $tson]} {
		return $tson
	    } else {
		return [qc::xml_escape $tson]
	    }
	}
    }
}