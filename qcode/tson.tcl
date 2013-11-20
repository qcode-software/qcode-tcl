package provide qcode 2.01
package require doc
namespace eval qc {
    namespace export tson_object json_quote tson2json tson_object_from tson2xml
}

proc qc::tson_object { args } {
    #| Return a tson object from list of name value pairs in args
    # Cannot be used to create nested objects
    # EXAMPLE:  
    # % tson_object firstname "Daniel" surname "Clark" age 23
    # object firstname {string Daniel} surname {string Clark} age 23

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
doc qc::tson_object {
    Examples {
	% qc::tson_object legs 4 eyes 2 coat fur call meow
	object legs 4 eyes 2 coat {string fur} call {string meow}
    }
}

proc qc::json_quote {value} {
    #| Return a json string literal with appropriate escapes
    return "\"[string map {\" \\\" \\ \\\\ \n \\n \r \\r \f \\f \b \\b \t \\t} $value]\""
}

doc qc::json_quote {
    Examples {
	% qc::json_quote {He said "Hello World!"}
	"He said \"Hello World!\""
    }
}

proc qc::tson2json { tson } {
    #| Convert tson to json
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

doc qc::tson2json {
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
    #| Take a list of var names and return a tson object
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

doc qc::tson_object_from {
    Examples {
	% set foo Hello
	Hello
	% set bar "World's Apart"
	World's Apart
	% qc::tson_object_from foo bar
	object foo {string Hello} bar {string {World's Apart}}
    }
}

proc qc::tson2xml { tson } {
    # not dealt with attributes 
    # prefered technique
    # http://www.ibm.com/developerworks/xml/library/x-xml2jsonphp/
    
    switch -- [lindex $tson 0] {
	object {
	    set list {}
	    foreach {name value} [lrange $tson 1 end] {
		lappend list <$name>[qc::tson2xml $value]</$name>
	    }
	    return [join $list "\n"]
	}
	array {
	    set list {}
	    foreach value [lrange $tson 1 end] {
		lappend list <item>[qc::tson2xml $value]</item>
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

doc qc::tson2xml {
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
	% qc::tson2xml $tson
	<Image><Width>800</Width>
	<Height>600</Height>
	<Title>View from the 15th Floor</Title>
	<Thumbnail><Url>http://www.example.com/image/481989943</Url>
	<Height>125</Height>
	<Width>100</Width></Thumbnail>
	<IDs><item>116</item><item>943</item><item>234</item><item>38793</item></IDs></Image>
    }
}
