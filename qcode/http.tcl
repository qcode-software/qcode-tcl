package provide qcode 2.1
package require doc
namespace eval qc {}

proc qc::http_curl {args} {
    #| This is a wrapper for TclCurl
    # If run within AOLserver uses ns_proxy to make thread safe.
    set script {
	proc main {args} {
	    package require TclCurl
	    set curlHandle [curl::init]
	    $curlHandle configure {*}$args
	    catch { $curlHandle perform } curlErrorNumber
	    set responsecode [$curlHandle getinfo responsecode]
	    $curlHandle cleanup
	    set dict {}
	    foreach var [info locals] {
		switch -- $var {
		    args -
		    dict -
		    curlHandle {}
		    default {
			if { [array exists $var] } {
			    lappend dict $var [array get $var]
			} else {
			    lappend dict $var [set $var]
			}
		    }
		}
	    }
	    return $dict
	}
    }
    append script [list main {*}$args]

    if { [info commands ns_proxy] eq "ns_proxy" } {
        # We are running under AOLserver so wrap with ns_proxy

        set handle [ns_proxy get myproxy]

        if { [dict exists $args -timeout] } {
	    # The proxy may timeout first due to a dns lookup so double timeout
	    set timeout [expr {[dict get $args -timeout]*1000*2}]
        } else {
	    # default timeout 60seconds
	    set timeout 60000
        }
        qc::try {
	    set dict [ns_proxy eval $handle $script $timeout]
	    ns_proxy release $handle
	    return $dict
        } {
	    ns_proxy release $handle
	    error $::errorMessage $::errorInfo $::errorCode
        }
    } else {
        # no ns_proxy so evaluate directly
        return [eval $script]
    }
}

proc qc::http_post {args} {
    #| Perform an HTTP POST
    # args is name value name value ... list
    # usage http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-accept accept? ?-authorization authorization? ?-data data? ?-valid_response_codes? ?-headers {name value name value ...}? url ?name value? ?name value?
    args $args -timeout 60 -sslversion sslv3 -encoding utf-8 -content-type ? -soapaction ? -accept ? -authorization ? -headers {} -data ? -valid_response_codes {100 200} url args

    if { ![info exists data]} {
	set pairs {}
	foreach {name value} $args {
	    lappend pairs "[qc::url_encode $name $encoding]=[qc::url_encode $value $encoding]"
	}
	set data [join $pairs &]

    }
    set httpheaders {}
    if { [info exists authorization] } {
	lappend httpheaders [qc::http_header "Authorization" $authorization]
    }

    if { [info exists content-type] } {
	lappend httpheaders [qc::http_header "Content-Type" ${content-type}]
    }

    if { [info exists accept] } {
	lappend httpheaders [qc::http_header "Accept" $accept]
    }

    if { [info exists soapaction] } {
	lappend httpheaders [qc::http_header "SOAPAction" $soapaction]
    }
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }
   
    dict2vars [qc::http_curl -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0  -timeout $timeout -sslversion $sslversion -bodyvar html -post 1 -httpheader $httpheaders -postfields $data] html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    if { [in $valid_response_codes $responsecode] } {
		return [encoding convertfrom [qc::http_encoding [array get return_headers] $html] $html]
	    } else {
		# raise an error
		switch $responsecode {
		    404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
		    500 {return -code error -errorcode CURL "SERVER ERROR $url $html"}
		    default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url $html"}
		}
	    }
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

doc qc::http_post {
    Usage { http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-accept accept? ?-authorization authorization? ?-data data? ?-valid_response_codes? ?-headers {name value name value ...}? url ?name value? ?name value? }
    Examples {
        % qc::http_post -timeout 30 -content-type "text/plain; charset=utf-8" -accept "text/plain; charset=utf-8" -- http://httpbin.org/post data "Here's the POST data"
        {
            "files": {},
            "form": {},
            "url": "http://httpbin.org/post",
            "args": {},
            "headers": {
                "Content-Length": "27",
                "Host": "httpbin.org",
                "Content-Type": "text/plain; charset=utf-8",
                "Connection": "keep-alive",
                "Accept": "text/plain; charset=utf-8"
            },
        "json": null,
        "data": "data=Here%27s+the+POST+data"
        }
    }
}

proc qc::http_get {args} {
    # usage http_get ?-timeout timeout? ?-headers {name value name value ...}? url
    args $args -timeout 60 -sslversion sslv3 -headers {} url

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }
   
    dict2vars [qc::http_curl  -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -sslversion $sslversion -followlocation 1 -httpheader $httpheaders  -bodyvar html] html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    switch $responsecode {
		200 { 
		    # OK
		    return [encoding convertfrom [qc::http_encoding [array get return_headers] $html] $html] 
		}
		404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
		500 {return -code error -errorcode CURL "SERVER ERROR $url"}
		default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
	    }
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

doc qc::http_get {
    Usage { http_get  ?-timeout timeout? ?-headers {name value name value ...}? url }
    Examples {
        > qc::http_get http://httpbin.org/get?ourformvar=999&anotherformvar=123
        {
        "url": "http://httpbin.org/get?ourformvar=999&anotherformvar=123",
        "headers": {
            "Content-Length": "",
            "Host": "httpbin.org",
            "Content-Type": "",
            "Connection": "keep-alive",
            "Accept": "*/*"
        },
        "args": {
            "anotherformvar": "123",
            "ourformvar": "999"
        },
        }
    }
}

proc qc::http_header {name value} {
    #| Return http header. 
    #| Raise an error if the value of the http header contains newline characters.
    if { [regexp {\n} $value] } {
        error "The value of http header, \"$name: $value\", contains newline characters."
    }
    return "$name: $value"
}

doc qc::http_header {
    Examples {
        % http_header Content-Type application/json
        Content-Type: application/json
    }
}

proc qc::http_put {args} {
    # usage http_put ?-header 0? ?-timeout timeout? ?-infile infile? ?-data data? ?-headers {name value name value ...}? url
    args $args -header 0 -timeout 60 -sslversion sslv3 -headers {} -infile ? -data ? url 

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders "$name: $value"
    }

    if { [info exists data] && [info exists infile]} {
        error "qc::http:put must have only 1 of -data or -infile specified"
    } elseif { [info exists infile] } {
        dict2vars [qc::http_curl -header $header -upload 1 -infile $infile -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -sslversion $sslversion -followlocation 1 -httpheader $httpheaders  -bodyvar html] html responsecode curlErrorNumber
    } elseif { [info exists data] }  {
        dict2vars [qc::http_curl -header $header -customrequest PUT -postfields $data -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -sslversion $sslversion -followlocation 1 -httpheader $httpheaders  -bodyvar html] html responsecode curlErrorNumber
    } else {
        error "qc::http:put must have 1 of -data or -infile specified"
    }

    switch $curlErrorNumber {
	0 {
	    switch $responsecode {
		200 { 
		    # OK
		    return [encoding convertfrom [qc::http_encoding [array get return_headers] $html] $html] 
		}
		404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
		500 {return -code error -errorcode CURL "SERVER ERROR $url"}
		default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
	    }
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

proc qc::http_encoding {headers body} {
    #| Return the TCL encoding scheme used for http.
    # Try to determine the http encoding from the following sources (in this order):
    #   * HTTP-Header (charset attribute)
    #   * XML declaration (encoding attribute)
    # Otherwise return iso8859-1 as the default http encoding.
    # TODO this defaults to iso8859-1 for non-xml, but xml_encoding defaults to utf-8
    # I suspect this should be updated to default to utf-8 also.
    set encoding [qc::http_header_encoding $headers]
    if { $encoding eq "" } {
	if { [regexp {^\s*<\?xml} $body] } {
	    # Its an XML document
	    set encoding [qc::xml_encoding $body]
	} else {
	    set encoding "iso8859-1"
	}
    }
    return $encoding
}

proc qc::http_header_encoding {dict} {
    #| Return the TCL encoding scheme for a http header dict.
    # Try to determine encoding from the charset attribute specified in the http header dict.
    # Otherwise return "".
    array set return_headers $dict
    set encoding ""
    foreach key {Content-Type content-type} {
        if { [info exists return_headers($key)] && [regexp -nocase {.*;.*charset=(.*)} $return_headers($key) -> charset] } {
	    set encoding [IANAEncoding2TclEncoding [string trim $charset]]
        }
    }
    return $encoding
}

#----------------------------------------------------------------------------
#   IANAEncoding2TclEncoding
#   From v0.82 tDom lib/tdom.tcl
#----------------------------------------------------------------------------

proc qc::IANAEncoding2TclEncoding {IANAName} {
    
    switch [string tolower $IANAName] {
        "us-ascii"    {return ascii}
        "utf-8"       {return utf-8}
        "utf-16"      {return unicode; # not sure about this}
        "iso-8859-1"  {return iso8859-1}
        "iso-8859-2"  {return iso8859-2}
        "iso-8859-3"  {return iso8859-3}
        "iso-8859-4"  {return iso8859-4}
        "iso-8859-5"  {return iso8859-5}
        "iso-8859-6"  {return iso8859-6}
        "iso-8859-7"  {return iso8859-7}
        "iso-8859-8"  {return iso8859-8}
        "iso-8859-9"  {return iso8859-9}
        "iso-8859-10" {return iso8859-10}
        "iso-8859-13" {return iso8859-13}
        "iso-8859-14" {return iso8859-14}
        "iso-8859-15" {return iso8859-15}
        "iso-8859-16" {return iso8859-16}
        "iso-2022-kr" {return iso2022-kr}
        "euc-kr"      {return euc-kr}
        "iso-2022-jp" {return iso2022-jp}
        "koi8-r"      {return koi8-r}
        "shift_jis"   {return shiftjis}
        "euc-jp"      {return euc-jp}
        "gb2312"      {return gb2312}
        "big5"        {return big5}
        "cp866"       {return cp866}
        "cp1250"      {return cp1250}
        "cp1253"      {return cp1253}
        "cp1254"      {return cp1254}
        "cp1255"      {return cp1255}
        "cp1256"      {return cp1256}
        "cp1257"      {return cp1257}

        "windows-1251" -
        "cp1251"      {return cp1251}

        "windows-1252" -
        "cp1252"      {return cp1252}    

        "iso_8859-1:1987" -
        "iso-ir-100" -
        "iso_8859-1" -
        "latin1" -
        "l1" -
        "ibm819" -
        "cp819" -
        "csisolatin1" {return iso8859-1}
        
        "iso_8859-2:1987" -
        "iso-ir-101" -
        "iso_8859-2" -
        "iso-8859-2" -
        "latin2" -
        "l2" -
        "csisolatin2" {return iso8859-2}

        "iso_8859-5:1988" -
        "iso-ir-144" -
        "iso_8859-5" -
        "iso-8859-5" -
        "cyrillic" -
        "csisolatincyrillic" {return iso8859-5}

        "ms_kanji" -
        "csshiftjis"  {return shiftjis}
        
        "csiso2022kr" {return iso2022-kr}

        "ibm866" -
        "csibm866"    {return cp866}
        
        default {
            error "Unrecognized encoding name '$IANAName'"
        }
    }
}
#----------------------------------------------------------------------------
# End of tDom code
#----------------------------------------------------------------------------

proc qc::http_head {args} {
    #| Return a dict of name value pairs returned by the server in the HTTP header
    # usage http_head ?-timeout timeout? ?-useragent useragent? url
    args $args -timeout 60 -useragent ? url
    default useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.7) Gecko/20060909 FreeBSD/i386 Firefox/1.5.0.7"
    #
    dict2vars [qc::http_curl -nobody 1 -header 1 -headervar headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1] headers responsecode curlErrorNumber


    switch $curlErrorNumber {
	0 {
	    switch $responsecode {
		200 { 
		    # OK 
		    return $headers
		}
		404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
		500 {return -code error -errorcode CURL "SERVER ERROR $url"}
		default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
	    }
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

doc qc::http_head {
    Examples {
	% qc::http_head www.google.co.uk
	% Expires -1 http {HTTP/1.1 200 OK} Transfer-Encoding chunked X-Frame-Options SAMEORIGIN Content-Type {text/html; charset=ISO-8859-1} Cache-Control {private, max-age=0} Date {Thu, 23 Aug 2012 14:42:23 GMT} X-XSS-Protection {1; mode=block} Server gws P3P {CP="This is not a P3P policy! See http://www.google.com/support/accounts/bin/answer.py?hl=en&answer=151657 for more info."} Set-Cookie {{PREF=ID=a756df18ac806a1b:FF=0:TM=1345732943:LM=1345732943:S=pks7ngzKuTVPwX92; expires=Sat, 23-Aug-2014 14:42:23 GMT; path=/; domain=.google.co.uk} {NID=63=RM68tXvZZYQ6EMUebcB7iyXIbKwXH1PoXgkNyomu_tF5-DBQ1vhBw_o8A_n0N-zhdNbTp7_eOZ8A90i3VsxT19TvuW9ld-kiidOfY-Tn8jaDVXs3C7i6em6ITp3MFLbn; expires=Fri, 22-Feb-2013 14:42:23 GMT; path=/; domain=.google.co.uk; HttpOnly}}
    }
}

proc qc::http_exists {args} {
    #| Test if an URL returns a valid response
    # usage http_head ?-timeout timeout? ?-useragent useragent? url
    args $args -timeout 60 -useragent ? -valid_response_codes {100 200} url
    default useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.7) Gecko/20060909 FreeBSD/i386 Firefox/1.5.0.7"
    #
    dict2vars [qc::http_curl  -nobody 1 -header 1 -headervar headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1] responsecode curlErrorNumber

    if { [in $valid_response_codes $responsecode] } {
	return true
    } else {
	return false
    }
}

doc qc::http_exists {
    Examples  {
	% qc::http_exists www.qcode.co.uk
	true
	
	% qc::http_exists www.qcode.co.uk/foo
	false
    }
}

proc qc::http_save {args} {
    #| Save the HTTP response to a file.
    args $args -timeout 60 -headers {} -- url file

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders "$name: $value"
    }

    dict2vars [qc::http_curl -httpheader $httpheaders -timeout $timeout -url $url -file $file -sslverifypeer 0 -sslverifyhost 0] responsecode curlErrorNumber
    if { $responsecode != 200 } {
	file delete $file
    }
    switch $responsecode {
	200 { 
	    # OK 
	}
	404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
	500 {return -code error -errorcode CURL "SERVER ERROR $url"}
	default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
    }
    switch $curlErrorNumber {
	0 {
	    # OK
	    return 1
	}
	default {
	    file delete $file
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

proc qc::http_delete {args} {
    #| Send http DELETE request
    args $args -timeout 60 -headers {} -- url

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders "$name: $value"
    }

    dict2vars [qc::http_curl -customrequest DELETE -httpheader $httpheaders -timeout $timeout -url $url -sslverifypeer 0 -sslverifyhost 0] responsecode curlErrorNumber
    switch $responsecode {
        204 -
	200 { 
	    # OK 
	}
	404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
	500 {return -code error -errorcode CURL "SERVER ERROR $url"}
	default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
    }
    switch $curlErrorNumber {
	0 {
	    # OK
	    return 1
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

