namespace eval qc {
    namespace export tson* json_quote
}


proc qc::tson_string {value} {
    #| Returns a TSON string.
    return [list string $value]
}

proc qc::tson_number {value} {
    #| Returns a TSON number.
    if { [string tolower $value] in [list "" "null"] } {
        return "null"
    }
    return [list number $value]
}

proc qc::tson_boolean {value} {
    #| Returns a TSON boolean.
    if { [string tolower $value] in [list "" "null"] } {
        return "null"
    }
    return [list boolean [qc::cast boolean $value true false]]
}

proc qc::tson_array {args} {
    #| Return a tson array from list of values.
    if { [llength $args] == 0 } {
        return "null"
    }
    
    set tson [list array]
    
    foreach value $args {
        if { [lindex $value 0] in [list object array string number boolean] } {
            lappend tson $value
        } elseif { ([qc::is decimal $value] && [qc::upper $value] ni [list NAN INF]) } {
            lappend tson [list number $value]
        } elseif { $value in [list true false] } {
            lappend tson [list boolean $value]
        } elseif { $value eq "null" } {
            lappend tson $value
        } else {
            lappend tson [list string $value]
        }
    }

    return $tson
}

proc qc::tson_object { args } {
    #| Return a tson object from list of name value pairs in args
    # Cannot be used to create nested objects
    # EXAMPLE:  
    # % tson_object firstname "Daniel" surname "Clark" age 23
    # object firstname {string Daniel} surname {string Clark} age {number 23}
    if { [llength $args] == 0 } {
        return "null"
    }
    
    set tson [list object]
    
    foreach {name value} $args {
        if { [lindex $value 0] in [list object array string number boolean] } {
            lappend tson $name $value
        } else {
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
    set path [qc::sql_list2array -type text $args]
    # Convert TSON to JSON.
    set json [qc::tson2json $tson]
    # Use PostgreSQL JSON operators to get the value at the path.
    qc::db_cache_1row -ttl 86400 {
        select :json::json#>>$path as value
    }

    return $value
}

proc qc::tson_exists {tson args} {
    #| Determines if a value exists at the specified path in the TSON.
    #| Requires PostgreSQL 9.3 or later.
    if { [llength $args] == 0 } {
        # No path specified.
        error "Usage: qc::tson_exists tson key ?key ...?"
    }

    # Check if the outermost key in the path exists.
    set json [qc::tson2json $tson]
    set key [lindex $args 0]
    
    switch [lindex $tson 0] {
        "object" {
            qc::db_cache_1row -ttl 86400 {
                select :key in (select json_object_keys(:json::json)) as key_exists
            }
        }
        "array" {
            qc::db_cache_1row -ttl 86400 {
                select json_array_length(:json::json) as array_length
            }
            
            if { $array_length == 0 || $key > $array_length - 1 } {
                # Array has no elements or key is out of bounds.
                return f
            }

            set key_exists t
        }
        default {
            error "TSON must be an object or an array."
        }
    }
    
    if { !$key_exists || [llength $args] == 1 } {
        # Key doesn't exist or no more keys in the path to check.
        return $key_exists
    }

    return [qc::tson_exists \
                [qc::json2tson [qc::tson_get $tson $key]] \
                {*}[lrange $args 1 end]]
}

proc qc::tson_type {tson args} {
    #| Returns the type of the value at the specified path in the TSON.
    #| Requires PostgreSQL 9.3 or later.
    set value_tson $tson
    
    if { [llength $args] > 0 } {
        # A path was specified so get the value at the path.

        if { ![qc::tson_exists $tson {*}$args] } {
            # Path doesn't existin the TSON.
            error "Path \"$args\" not found in TSON."
        }
        
        # Construct a PostgreSQL array literal from the path.
        set path [qc::sql_list2array -type text $args]
        
        # Convert TSON to JSON.
        set json [qc::tson2json $tson]
        
        # Use PostgreSQL JSON operators to get the value at the path.
        qc::db_cache_1row -ttl 86400 {
            select :json::json#>$path as value
        }
        
        # Convert the JSON to TSON.
        set value_tson [qc::json2tson $value]
    }

    if { $value_tson in [list "true" "false"] } {
        return "boolean"
    } elseif { [qc::is decimal $value_tson] } {
        return "number"
    } elseif { $value_tson eq "null" } {
        return "null"
    } elseif { [lindex $value_tson 0] in [list "object" "array" "string"] } {
        return [lindex $value_tson 0]
    } else {
        error "Invalid TSON."
    }
}

proc qc::tson_array_foreach {varName tson code} {
    #| Iterator for a tson array.
    foreach element [lrange $tson 1 end] {
        upset 1 $varName $element
        uplevel 1 $code
    }
}
