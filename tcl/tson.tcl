namespace eval qc {
    namespace export tson_object json_quote tson2json tson_object_from tson2xml tson_get
}

proc qc::tson_object { args } {
    #| Return a tson object from list of name value pairs in args
    # Cannot be used to create nested objects
    # EXAMPLE:  
    # % tson_object firstname "Daniel" surname "Clark" age 23
    # object firstname {string Daniel} surname {string Clark} age {number 23}

    set tson [list object]
    
    foreach {name value} $args {
	if { ([qc::is decimal $value] && [qc::upper $value] ni [list NAN INF]) } {
            lappend tson $name [list number $value]
        } elseif { $value in [list true false] } {
	    lappend tson $name [list boolean $value]
	} elseif { $value eq "null" } {
	    lappend tson $name $value
	} else { 
	    lappend tson $name [list string $value]
	}
    }

    return $tson
}

proc qc::json_quote {value} {
    #| Return a json string literal with appropriate escapes
    return "\"[string map {\" \\\" \\ \\\\ \n \\n \r \\r \f \\f \b \\b \t \\t} $value]\""
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
        number {
            return [lindex $tson 1]
        }
        boolean {
            return [lindex $tson 1]
        }
	default {
	    if { ([string is double -strict $tson] && [qc::upper $tson] ni [list NAN INF]) || [in {true false null} $tson]} {
		return $tson
	    } else {
		return [json_quote $tson]
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
        number {
            return [lindex $tson 1]
        }
        boolean {
            return [lindex $tson 1]
        }
	default {
	    if { ([string is double -strict $tson] && [qc::upper $tson] ni [list NAN INF]) || [in {true false null} $tson]} {
		return $tson
	    } else {
		return [qc::xml_escape $tson]
	    }
	}
    }
}

proc qc::tson_get {tson args} {
    #| Returns the value at the specified path in the TSON.
    #| Requires PostgreSQL 9.3 or later.

    # Construct a PostgreSQL array literal from the path.
    set path "\{[join $args ","]\}"
    # Convert TSON to JSON.
    set json [qc::tson2json $tson]
    # Use PostgreSQL JSON operators to get the value at the path.
    qc::db_cache_1row -ttl 86400 {
        select :json::json#>>:path as value
    }

    return $value
}