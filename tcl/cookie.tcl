
package require doc
namespace eval qc {
    namespace export cookie_*
}

doc cookie {
    Title "Cookie Handling"
    Url {/qc/wiki/CookiePage}
}

proc qc::cookie_string_is_valid {cookie_string} {
    #| Test if the cookie string conforms to the RFC
    set re {
        ^
        ([^[:cntrl:]()<>@,;:\\\"/\[\]?={}\ \t]+
        =
        (\"[^[:cntrl:]\s\",;\\]*\"|[^[:cntrl:]\s\",;\\]*)
        (
         ;\ [^[:cntrl:]()<>@,;:\\\"/\[\]?={}\ \t]+
         =
         (\"[^[:cntrl:]\s\",;\\]*\"|[^[:cntrl:]\s\",;\\]*)
         )*)?
        $
    }
    return [regexp -expanded $re $cookie_string]
}

proc qc::cookie_string2multimap {cookie_string} {
    #| Extracts a multimap of name-value pairs from a cookie string
    set cookie_map {}
    set cookie_string [trim $cookie_string]
    if { [string first ";" $cookie_string] == -1 && [string first = $cookie_string] == -1 } {
        return $cookie_map
    }
    while { $cookie_string ne "" } {
        set index [string first ";" $cookie_string]
        if { $index == -1 } {
            set cookie_fragment $cookie_string
            set cookie_string ""
        } else {
            set cookie_fragment [string range $cookie_string 0 [expr {$index - 1}]]
            set cookie_string [string range $cookie_string [expr {$index + 1}] end]
        }
        set index2 [string first = $cookie_fragment]
        if { $index2 == -1 } {
            set name $cookie_fragment
            set value ""
        } else {
            set name [string range $cookie_fragment 0 [expr {$index2 - 1}]]
            set value [string range $cookie_fragment [expr {$index2 + 1}] end]
        }
        set name [string trim $name]
        set value [string trim $value]
        if { [string index $value 0] eq "\"" && [string index $value end] eq "\"" } {
            set value [string range $value 1 end-1]
        }
        if { $name ne "" } {
            lappend cookie_map [qc::url_decode $name] [qc::url_decode $value]
        }
    }
    return $cookie_map
}

proc qc::cookie_get { search_name } {
    #| Get a cookie value or throw an error
    set headers [ns_conn headers]
    set cookie_string [ns_set iget $headers Cookie]
    set cookie_map [qc::cookie_string2multimap $cookie_string]
    if { [multimap_exists $cookie_map $search_name] } {
        return [multimap_get_first $cookie_map $search_name]
    } else {
	error "Cookie [qc::url_decode $search_name] does not exist"
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
    set cookie_string [ns_set iget $headers Cookie]
    if { ! [qc::cookie_string_is_valid $cookie_string] } {
        return false
    }
    set cookie_map [qc::cookie_string2multimap $cookie_string]
    return [multimap_exists $cookie_map [qc::url_encode $name]]
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
