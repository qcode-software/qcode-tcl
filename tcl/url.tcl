namespace eval qc {
    namespace export url url_*
}

proc qc::url { url args } {
    #| Builds a URL from a given base and name value pairs.
    #| Substitutes any colon variables from the name value pairs into the path and fragment
    #| with any remaining name value pairs treated as parameters for the query string.
    #| NOTE: Only supports root-relative URLs.
    set dict [qc::args2dict $args]

    # base, params, hash, protocol, domain, port, path, segments
    qc::dict2vars [qc::url_parts $url]

    # look for colon vars in the URL path segments and substitute the matching value given in the args
    set substituted_segments [list]
    foreach segment $segments {
        if { [string index $segment 0] eq ":" } {
            # remove the colon
            set segment [string range $segment 1 end]
            # check if caller has provided a substitution for the segment
            if { [dict exists $dict $segment] } {
                lappend substituted_segments [dict get $dict $segment]
                # remove the dict entry so that it isn't reused
                set dict [dict remove $dict $segment]
            } else {
                error "Missing value to go with key \"$segment\" in args"
            }
        } else {
            lappend substituted_segments $segment
        }
    }

    # check if the fragment identifier requires substitution
    if { [string index $hash 0] eq ":" } {
        # remove the colon
        set temp [string range $hash 1 end]
        if { [dict exists $dict $temp] } {
            set hash [dict get $dict $temp]
            # remove the dict entry so that it isn't reused
            set dict [dict remove $dict $temp]
        } else {
            error "Missing value to go with key \"$hash\" in args"
        }
    }

    # rest of args are form vars
    dict for {key value} $dict {
        # overwrite any existing form vars
        dict set params $key $value
    }

    return [qc::url_make [dict create protocol $protocol domain $domain port $port segments $substituted_segments params $params hash $hash]]
}

proc qc::url_unset { url var_name } {
    #| Unset a url encoded variable in url
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    if { [regexp {([^\?\#]+)(?:\?([^\#]*))?(\#.*)?} $url -> path query_string fragment] } {
	foreach {name value} [split $query_string &=] {
	    set this([qc::url_decode $name]) [qc::url_decode $value]
	}
    } else {
       	array set this {}
    }
    # Unset required value
    if { [info exists this($var_name)] } {
	unset this($var_name)
    }
    # Recontruct the query string
    set pairs {}
    foreach name [array names this] {
	lappend pairs "[url_encode $name]=[url_encode $this($name)]"
    }
    if { [llength $pairs] != 0 } {
	return "$path?[join $pairs &]$fragment"
    } else {
	return ${path}${fragment}
    }
}

proc qc::url_to_html_hidden { url } {
    #| Convert a url with form vars into html hidden input tags
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    set html ""
    if { [regexp {([^\?\#]+)(?:\?([^\#]*))?} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([qc::url_decode $name]) [qc::url_decode $value]
	}
    } else {
	array set this {}
    }
    append html [html_hidden_set {*}[array get this]]
    return $html
}

proc qc::url_back { url args } {
    #| Creates a link to url with a formvar next_url which links back to the current page.
    #| Preserve vars passed in via GET or POST
    # TODO Aolserver only
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    foreach name $args {
	set value($name) [upset 1 $name]
    }
    set value(next_url) [qc::url_here]
    return [url $url {*}[array get value]]
}

proc qc::url_here {} {
    #| Encode form_vars from GET and POST in this url.
    # TODO Aolserver only
    return [qc::form2url [qc::conn_url]]
}

proc qc::url_encoding_init {} {
    #| Initialise url encode/decode maps in the qc namespace
    variable url_encode_map {}
    variable url_decode_map {}
    for {set i 0} {$i < 256} {incr i} {
        set char [format %c $i]
        set hex %[format %02x $i]
        # RFC 3986 - Encode all characters except ( a-z A-Z 0-9 . - ~ _ )
        if { ! [string match {[-a-zA-Z0-9.~_]} $char] } {
            lappend url_encode_map $char $hex
        }
        # Decode any percent hex encoded characters
        lappend url_decode_map $hex $char
        # Decode + char as a space
        lappend url_decode_map + " " 
    }    
}

proc qc::url_encode {string {charset utf-8}} { 
    #| Return url-encoded string with option to specify charset    
    # Conforms to RFC 3986
    variable url_encode_map
    if { ! [info exists url_encode_map] } { 
        url_encoding_init 
    }
    return [string map $url_encode_map [encoding convertto $charset $string]]
}

proc qc::url_decode {string {charset utf-8}} { 
    #| Return url-decoded string with option to specify charset
    # Conforms to RFC 3986
    variable url_decode_map
    if { ! [info exists url_decode_map] } { 
        url_encoding_init 
    }
    return [encoding convertfrom $charset [string map -nocase $url_decode_map $string]]
}

proc qc::url_path {url} {
    # Return just the url path
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    if { [regexp {^https?://[a-z0-9_]+(?:\.[a-z0-9_\-]+)+(?::[0-9]+)?(/[^\?]*)} $url -> path] } {
	return $path
    } elseif { [regexp {^(/?[^\?]*)} $url -> path] } {
	return $path 
    } else {
	return ""
    }
}

proc qc::url_root {url} {
    # Return the root of an url without GET string or anchor
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    if { [regexp {^https?://[a-z0-9_][a-z0-9_\-]*(?:\.[a-z0-9_\-]+)+(?::[0-9]+)?(/[^\?\#]*)?} $url root] } {
	return $root
    } else {
        error "Url \"$url\" is not a valid URL"
    }
}

proc qc::url_match {canonical_url test_url} {
    #| Test if a test url matches a "canonical" url.
    # To match, they must have the same base, if the canonical url has a hash then
    # the test url must have the same hash, and every name/value pair in the
    # canonical url's query must appear at least the same number of times in the
    # test url's query.

    set c_parts [url_parts $canonical_url]
    set t_parts [url_parts $test_url]
    if { [dict get $c_parts base] ne [dict get $t_parts base] } {
        return false
    }
    if { [dict get $c_parts hash] ni [list "" [dict get $t_parts hash]] } {
        return false
    }

    set c_params [dict get $c_parts params]
    set t_params [dict get $t_parts params]
    foreach {c_name c_value} $c_params {
        set matched false
        foreach {t_name t_value} $t_params {
            if { $c_name eq $t_name
                 && $c_value eq $t_value } {
                multimap_unset_first t_params $c_name $t_value
                set matched true
                break
            }
        }
        if { ! $matched } {
            return false
        }
    }

    return true
}

proc qc::url_parts {url} {
    #| Return a dict containing the base, params (as a multimap), hash, protocol, domain, port,
    # and path of url
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }  
    set pchar {[a-zA-Z0-9\-._~]|%[0-9a-fA-F]{2}|[!$&'()*+,;=:@]}
    set query_char "(?:${pchar}|/|\\?)"
    set hash_char "(?:${pchar}|/|\\?)"
    set path_char "(?:${pchar}|/)"

    set pattern [subst -nocommands -nobackslashes {^
        # base with protocol, domain, port (optional), and abs_path (optional)
        (
         (https?)://
         ([a-z0-9\-\.]+)
         (?::([0-9]+))?
         (/${path_char}*)?
         )
        
        # query (optional)
        (?:\?(${query_char}*))?
        
        # hash (optional)
        (?:\#(${hash_char}*))?
        $}]
    if { [regexp -expanded $pattern $url -> base protocol domain port path query hash] } {
        set params [split $query &=]
        set segments [split [string trimleft $path "/"] "/"]
        return [qc::dict_from base params hash protocol domain port path segments]
    }

    set pattern [subst -nocommands -nobackslashes {^
        # base with path (abs or rel) only
        (${path_char}*)
        
        # query (optional)
        (?:\?(${query_char}*))?
        
        # hash (optional)
        (?:\#(${hash_char}*))?
        $}]
    if { [regexp -expanded $pattern $url -> path query hash] } {
        lassign [list "" "" ""] protocol domain port
        set base $path
        set params [split $query &=]
        set segments [split [string trimleft $path "/"] "/"]
        return [qc::dict_from base params hash protocol domain port path segments]
    }

    error "Unable to parse url $url"
}

proc qc::url_request_path {request} {
    #| Return the path of an http request line
    # (eg. takes "GET /homepage?foo=bar HTTP/1.1", returns "/homepage")
    set request_regexp {^
        ([A-Z]+)
        \s
        ([^ ]+)
        \s
        HTTP/([0-9]+\.[0-9]+)
        $}
    if { ! [regexp -expanded $request_regexp $request \
                -> request_method request_uri http_version] } {
        error "bad request line"
    }
    set parts [qc::url_parts $request_uri]
    return [dict get $parts path]
}

proc qc::url_make {dict} {
    #| Construct an url from a dict of parts
    # eg.
    # url_make {
    #     protocol https
    #     domain qcode.co.uk
    #     port 80
    #     segments {posts 123 "hello world"}
    #     params {tags tcl tags psql author peter}
    #     hash comments
    # }
    # => https://qcode.co.uk:80/posts/123/hello+world?tags=tcl&tags=psql&author=peter#comments
    # all keys are optional, but if protocol, domain, and/or port are specified,
    #   protocol and domain must be specified)
    # "segments" is a list
    # "params" is a multimap
    # If segments is specified (even as an empty list), the url path will be absolute
    dict2vars $dict protocol domain port segments params hash

    # Construct url root (eg. http://qcode.co.uk:80).
    if {
        ([info exists protocol] && $protocol ne "")
        || ([info exists domain] && $domain ne "")
        || ([info exists port] && $port ne "")
    } {
        if { ! ([info exists protocol] && $protocol ne "") } {
            error "Invalid url dict - domain or port without protocol"
        }
        if { ! ([info exists domain] && $domain ne "") } {
            error "Invalid url dict - protocol or port without domain"
        }
        if { ! [regexp {https?} $protocol] } {
            error "Invalid url protocol $protocol"
        }
        if { ! [regexp {[a-z0-9\-\.]+} $domain] } {
            error "Invalid url domain $domain"
        }
        if { ([info exists port] && $port ne "") } {
            if { ! [regexp {[0-9]+} $port] } {
                error "Invalid url port $port"
            }
            set root "${protocol}://${domain}:${port}"
        } else {
            set root "${protocol}://${domain}"
        }
    }

    # Construct url path (eg. /posts/123/hello-world).
    if { [info exists segments] } {
        set segments_escaped [list]
        foreach segment $segments {
            lappend segments_escaped [url_encode $segment]
        }
        set path "/[join $segments_escaped "/"]"
    }

    # Construct url query (eg. tags=tcl&tags=psql&author=peter).
    if { [info exists params] && [llength $params] > 0 } {
        if { [llength $params] % 2 != 0 } {
            error "Invalid params multimap $params"
        }
        set pairs [list]
        foreach {name value} $params {
            lappend pairs "[url_encode $name]=[url_encode $value]"
        }
        set query "[join $pairs "&"]"
    }

    # Encode hash into url "fragment"
    if { [info exists hash] && $hash ne "" } {
        set fragment [url_encode $hash]
    }

    # Bring the parts together into an url
    set url ""
    if { [info exists root] } {
        append url $root
    }
    if { [info exists path] } {
        append url $path
    }
    if { [info exists query] } {
        append url "?$query"
    }
    if { [info exists fragment] } {
        append url "#$fragment"
    }

    return $url
}

proc qc::url_maker {args} {
    #| Construct or modifiy an url
    # Usage url_maker [$base] [: $port] [/ [segment ...]] [? [param_name param_value ...]] [# [hash]]
    qc::args $args -multimap_form_vars -- args
    default multimap_form_vars false
    set usage_error {Usage: url_maker [$base [: $port]] [/ [segment ...]] [? [param_name param_value ...]] [# [hash]] }
    set url_dict [dict create]
    set section "base"
    set sections [list "base" "port" "segments" "params" "hash"]
    set delimiters {
        ":" "port"
        "/" "segments"
        "?" "params"
        "#" "hash"
    }
    set end_of_section false
    set arg_is_param_value false
    set current_param_name ""
    foreach arg $args {
        if { [dict exists $delimiters $arg] } {
            if { $arg_is_param_value } {
                error $usage_error
            }
            set new_section [dict get $delimiters $arg]
            set old_index [lsearch $sections $section]
            set new_index [lsearch $sections $new_section]
            if { $new_index <= $old_index } {
                error $usage_error
            }
            set section $new_section
            switch $section {
                "port" {
                    dict set url_dict port ""
                }
                "segments" {
                    dict_default url_dict segments [list]
                }
                "params" {
                    if { $multimap_form_vars } {
                        dict_default url_dict params [list]
                    } else {
                        dict_default url_dict params [dict create]
                    }
                }
                "hash" {
                    dict set url_dict hash ""
                }
            }
            set end_of_section false
        } else {
            if { $end_of_section } {
                error $usage_error
            }
            if { [string index $arg 0] eq ":" } {
                set value [uplevel set [string range $arg 1 end]]
            } else {
                set value $arg
            }
            switch $section {
                "base" {
                    if { $value ne "" } {
                        set url_dict [qc::url_parts $value]
                    }
                    set end_of_section true
                }
                "port" {
                    dict set url_dict port $value
                    set end_of_section true
                }
                "segments" {
                    dict lappend url_dict segments $value
                }
                "params" {
                    if { $multimap_form_vars } {
                        dict lappend url_dict params $value
                    } else {
                        if { $arg_is_param_value } {
                            dict set url_dict params $current_param_name $value
                            set arg_is_param_value false
                        } else {
                            set current_param_name $value
                            set arg_is_param_value true
                        }
                    }
                }
                "hash" {
                    dict set url_dict hash $value
                    set end_of_section true
                }
            }
        }
    }
    if { $arg_is_param_value } {
        error $usage_error
    }
    return [qc::url_make $url_dict]
}