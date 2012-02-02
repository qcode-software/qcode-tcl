package provide qcode 1.4
package require doc
namespace eval qc {}

proc qc::url { url args } {
    #| Take an url with or without url encoded vars
    #| and insert or replace the names in vars with the 
    #| values in callers namespace level $level
    #| Example:
    #| > set foo Hello
    #| There
    #| > set bar There
    #| There
    #| > url afile.html foo bar
    #| afile.html?foo=Hello&bar=There
    #
    # Are there existing encoded vars path?var1=name1...
    set dict [args2dict $args]
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
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
	return "$path?[join $pairs &]"
    } else {
	return $path
    }
}

proc qc::url_unset { url var_name } {
    #| Unset a url encoded variable in url
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
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
	return "$path?[join $pairs &]"
    } else {
	return $path
    }
}

proc qc::url_to_html_hidden { url } {
    set html ""
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
	}
    } else {
	array set this {}
    }
    append html [html_hidden_set [array get this]]
    return $html
}

proc qc::url_back { url args } {
    #| Link to url using next_url to come back 
    #| Preserve vars passed in via GET or POST
    foreach name $args {
	set value($name) [upset 1 $name]
    }
    set value(next_url) [url_here]
    return [url $url [array get value]]
}

proc qc::url_here {} {
    return [qc::form2url [qc::conn_url]]
}

proc qc::url_encode {string {charset utf-8}} {
    return [string map {%2e . %2E . %7e ~ %7E ~ %2d - %2D - %5f _ %5F _} [ns_urlencode -charset $charset $string]]
}

proc qc::url_path {url} {
    set path $url
    regexp {^([^\?]+)} $url -> path
    return $path
}