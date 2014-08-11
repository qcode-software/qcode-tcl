
package require doc
namespace eval qc {
    namespace export cookie_*
}

doc cookie {
    Title "Cookie Handling"
    Url {/qc/wiki/CookiePage}
}

proc qc::cookie_get { name } {
    #| Get a cookie value or throw an error
    set headers [ns_conn headers]
    set cookie [ns_set iget $headers Cookie]
    # Be relaxed about encoding names
    if { [set start [string first " [url_encode $name]=" " $cookie"]] != -1 \
	     || [set start [string first " [qc::url_encode $name]=" " $cookie"]] != -1 \
	     || [set start [string first " $name=" " $cookie"]] != -1  } {
	set start [string first "=" $cookie $start]
	if { [set end [string first ";" $cookie $start]]!=-1 } {
	    return [qc::url_decode [string range $cookie [expr {$start+1}] [expr {$end-1}]]]
	} else {
	    return [qc::url_decode [string range $cookie [expr {$start+1}] end]]
	}
    } else {
	error "Cookie [qc::url_decode $name] does not exist"
    }
}

doc qc::cookie_get {
    Parent cookie
    Examples {
	% cookie_get session_id
	12345654321
	% 
	% If the cookie cannot be found an error is thrown
	% cookie_get foo
	Cookie foo does not exist
    }
}

proc qc::cookie_exists { name } {
    #| Test if the cookie exists
    if { ![ns_conn isconnected] } {
	return false
    }
    set headers [ns_conn headers]
    set cookie [ns_set iget $headers Cookie]
    if { [string first "[url_encode $name]=" $cookie] != -1 \
	     || [set start [string first "[qc::url_encode $name]=" $cookie]] != -1 \
	     || [string first "$name=" $cookie] != -1 } {
	return true
    } else {
	return false
    }
}

doc qc::cookie_exists {
    Parent cookie
    Examples {
	% cookie_exists session_id
	true
	%
	% cookie_exists foo
	false
    }
}

proc qc::cookie_set {name value args} {
    #| Set a cookie in outgoing headers for the current conection.
    #| Optional named args:
    #| expires datetime, max_age seconds
    #| domain url, path path ,secure boolean
    # All browsers seem to support Expires but not all support max-age
    # which is supposed to supersede Expires RFC 2109
    array set option $args
    default option(secure) false
    # http_only means cookie is not available to JavaScript.
    default option(http_only) true
    default option(path) /
    set headers [ns_conn outputheaders]
    set cookie "[url_encode $name]=[url_encode $value]"

    if { [info exists option(path)] } {
        append cookie "; path=$option(path)"
    }

    if { [info exists option(max_age)] } {
        append cookie "; max-age=$option(max_age)"
    }

    if { [info exists option(expires)] } {
        append cookie "; expires=[ns_httptime [cast_epoch $option(expires)]]"
    }

    if { [info exists option(domain)] } {
        append cookie "; domain=$option(domain)"
    }

    if { [string is true $option(secure)] } {
        append cookie "; secure"
    }

    if { [string is true $option(http_only)] } {
        append cookie "; HttpOnly"
    }

    ns_set put $headers "Set-Cookie" $cookie
}

doc qc::cookie_set {
    Parent cookie
    Examples {
	% cookie_set tracking Google expires "+30 days"
	%
	# delete a cookie
	% cookie_set tracking "" expires yesterday
    }
}
