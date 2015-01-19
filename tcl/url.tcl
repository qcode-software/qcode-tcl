namespace eval qc {
    namespace export url url_*
}

proc qc::url { url args } {
    #| Take an url with or without url encoded vars and insert or replace vars based on 
    #| the supplied pairs of var & value.
    # TODO Aolserver only
    if { ![qc::is uri $url] } {
        error "\"$url\" is not a valid URI."
    }    
    # Are there existing encoded vars path?var1=name1...
    set dict [args2dict $args]
    if { [regexp {([^\?\#]+)(?:\?([^\#]*))?(\#.*)?} $url -> path query_string fragment] } {
	foreach {name value} [split $query_string &=] {
	    set this([qc::url_decode $name]) [qc::url_decode $value]
	}
    } else {
	error "\"$url\" is not a valid URL."
    }
    # Reset required values overwriting old values
    array set this $dict
    # Recontruct the query string
    set pairs {}
    foreach {name value} [array get this] {
	lappend pairs "[url_encode $name]=[url_encode $value]"
    }
    if { [llength $pairs] != 0 } {
	return "$path?[join $pairs &]$fragment"
    } else {
	return ${path}${fragment}
    }
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
        (?:\?(${query_char}+))?
        
        # hash (optional)
        (?:\#(${hash_char}+))?
        $}]
    if { [regexp -expanded $pattern $url -> base protocol domain port path query hash] } {
        set params [split $query &=]
        return [qc::dict_from base params hash protocol domain port path]
    }

    set pattern [subst -nocommands -nobackslashes {^
        # base with path (abs or rel) only
        (${path_char}+)
        
        # query (optional)
        (?:\?(${query_char}+))?
        
        # hash (optional)
        (?:\#(${hash_char}+))?
        $}]
    if { [regexp -expanded $pattern $url -> path query hash] } {
        lassign [list "" "" ""] protocol domain port
        set base $path
        set params [split $query &=]
        return [qc::dict_from base params hash protocol domain port path]
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