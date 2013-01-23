package provide qcode 1.13
package require doc
namespace eval qc {}

proc qc::url { url args } {
    #| Take an url with or without url encoded vars and insert or replace vars based on 
    #| the supplied pairs of var & value.
    # TODO Aolserver only

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

doc qc::url {
    Description {
        Take an url with or without url encoded vars and insert or replace vars based on<br> 
        the supplied pairs of var & value.
    }
    Usage {
        qc::url url ?var value? ...
    }
    Examples {
        % qc::url afile.html?foo=Goodbye foo "Hello" bar "There"
        afile.html?foo=Hello&bar=There
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

doc qc::url_unset {
    Description {
        Unset a url encoded variable in url
    }
    Usage {
        qc::url_unset url var_name
    }
    Examples {
        > qc::url_unset afile.html?foo=Hello&bar=There bar
        afile.html?foo=Hello
    }
}

proc qc::url_to_html_hidden { url } {
    #| Convert a url with form vars into html hidden input tags
    set html ""
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
	}
    } else {
	array set this {}
    }
    append html [html_hidden_set {*}[array get this]]
    return $html
}

doc qc::url_to_html_hidden {
    Description {
        Convert a url with form vars into html hidden input tags.<br>
    }
    Usage {
        qc::url_to_html_hidden url
    }
    Examples {
        > qc::url_to_html_hidden afile.html?foo=Hello&bar=There
        <input type="hidden" name="foo" value="Hello" id="foo">
        <input type="hidden" name="bar" value="There" id="bar">
    }
}

proc qc::url_back { url args } {
    #| Creates a link to url with a formvar next_url which links back to the current page.
    #| Preserve vars passed in via GET or POST
    # TODO Aolserver only
    foreach name $args {
	set value($name) [upset 1 $name]
    }
    set value(next_url) [url_here]
    return [url $url {*}[array get value]]
}

doc qc::url_back {
    Description {
        Creates a link to url with a formvar next_url which links back to the current page.<br>
        Preserve vars passed in via GET or POST
    }
    Usage {
        qc::url_back url args
    }
    Examples {
        set order_number 911
        set html [html_a "Do something to order $order_number and return" [url_back destination.html order_number]] 
        <a href="destination.html?order_number=911&amp;next_url=https%3a%2f%2fwww.domain.co.uk%2fsource.html%3forder_number%3d911">Do something to order 911 and return</a>
    }
}

proc qc::url_here {} {
    #| Encode form_vars from GET and POST in this url.
    # TODO Aolserver only
    return [qc::form2url [qc::conn_url]]
}

doc qc::url_here {
    Description {
        Encode form_vars from GET and POST in this url.
    }
    Usage {
        qc::url_here
    }
    Examples {
        # On page somePage.html?order_number=911
        set return_url [url_here]
    }
}


proc qc::url_encode {string {charset utf-8}} {
    #| Return url-encoded string with option to specify charset
    # TODO Aolserver only
    return [string map {%2e . %2E . %7e ~ %7E ~ %2d - %2D - %5f _ %5F _} [ns_urlencode -charset $charset $string]]
}

doc qc::url_encode {
    Description {
        Return url-encoded string with option to specify charset
    }
    Usage {
        qc::url_encode string ?charset? 
    }
    Examples {
        > qc::url_encode "someplace.html?order_number=911&title=casáu"
        someplace.html%3forder_number%3d911%26title%3dcas%c3%a1u
        > qc::url_encode "someplace.html?order_number=911&title=casáu" iso8859-1
        someplace.html%3forder_number%3d911%26title%3dcas%e1u
    }
}

proc qc::url_path {url} {
    # Return just the url path
    if { [regexp {^https?://[a-z0-9_]+(?:\.[a-z0-9_\-]+)+(?::[0-9]+)?(/[^\?]+)} $url -> path] } {
	return $path
    } elseif { [regexp {^(/[^\?]+)} $url -> path] } {
	return $path 
    } else {
	return ""
    }
}

doc qc::url_path {
    Description {
        Return just the url path 
    }
    Usage {
        qc::url_path url
    }
    Examples {
        % qc::url_path "/someplace.html?order_number=911&title=casáu"
        /someplace.html
    }
}
