namespace eval qc {
    namespace export http_* IANAEncoding2TclEncoding
}

proc qc::http_curl {args} {
    #| This is a wrapper for TclCurl
    # If run within AOLserver uses ns_proxy to make thread safe.
    set script {
	proc main {args} {
	    package require TclCurl
	    set curlHandle [curl::init]
            if { [set index [lsearch $args -infovar]]!=-1 } {
                set infovar [lindex $args [expr {$index+1}]]
                set args [lreplace $args $index [expr {$index+1}]]
            }
	    $curlHandle configure {*}$args
	    catch { $curlHandle perform } curlErrorNumber
	    set responsecode [$curlHandle getinfo responsecode]
            if { [info exists infovar] } {
                foreach property {effectiveurl httpcode responsecode filetime totaltime namelookuptime connecttime pretransfertime starttransfertime sizeupload sizedownload speeddownload speedupload headersize requestsize sslverifyresult contentlengthdownload contentlengthupload contenttype} { 
                    dict set $infovar $property [$curlHandle getinfo $property] 
                }
            }
	    $curlHandle cleanup
	    set dict {}
	    foreach var [info locals] {
		switch -- $var {
		    args -
		    dict -
                    infovar -
                    index -
                    property -
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
        ::try {
	    set dict [ns_proxy eval $handle $script $timeout]
	    ns_proxy release $handle
	    return $dict
        } on error {error_message options} {
	    ns_proxy release $handle
	    error $error_message [dict get $options -errorinfo] [dict get $options -errorcode]
        }
    } else {
        # no ns_proxy so evaluate directly
        return [eval $script]
    }
}

proc qc::http_post {args} {
    #| Perform an HTTP POST
    # args is name value name value ... list
    args \
        $args \
        -noproxy \
        -timeout 60 \
        -sslversion tlsv1 \
        -encoding utf-8 \
        -content-type ? \
        -soapaction ? \
        -accept ? \
        -authorization ? \
        -headers {} \
        -data ? \
        -filename ? \
        -valid_response_codes [list 100 200] \
        -response_headers false \
        -response_code false \
        url \
        args

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
   
    set curl_args [list \
                      {*}[qc::iif [info exists noproxy] {-proxy ""} {}] \
                      -headervar return_headers \
                      -url $url \
                      -sslverifypeer 0 \
                      -sslverifyhost 0 \
                      -timeout $timeout \
                      -sslversion $sslversion \
                      -bodyvar html \
                      -post 1 \
                      -httpheader $httpheaders \
                   ]

    if { [info exists content-type] && [string match "multipart/*" ${content-type}] } {
        # eg. multipart/formdata
        foreach mimepart $data {
            lappend curl_args -httppost $mimepart
        }
      
    } else {
        # eg. application/x-www-form-urlencoded
        lappend curl_args -postfields $data
    }

    if { [info exists filename] } {
        lappend curl_args -file $filename
    }

    dict2vars [qc::http_curl {*}$curl_args] return_headers html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    if { [in $valid_response_codes $responsecode] } {
		set response_body [encoding convertfrom [qc::http_encoding $return_headers $html] $html]
                if { !$response_headers && !$response_code } {
                    # Only return the response body.
                    return $response_body
                } else {
                    # User has requested response headers and/or code alongside the response body.
                    set response [dict create \
                                      body $response_body \
                                     ]

                    if { $response_code } {
                        dict set response code $responsecode
                    }

                    if { $response_headers } {
                        dict set response headers $return_headers
                    }

                    return $response
                }
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

proc qc::http_get {args} {
    # usage http_get ?-timeout timeout? ?-headers {name value name value ...}? ?-noproxy? url
    args \
        $args \
        -timeout 60 \
        -sslversion tlsv1 \
        -headers {} \
        -valid_response_codes {200} \
        -noproxy \
        -response_headers false \
        -response_code false \
        -- \
        url

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }
    dict2vars [qc::http_curl {*}[qc::iif [info exists noproxy] {-proxy ""} {}] -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -sslversion $sslversion -followlocation 1 -httpheader $httpheaders  -bodyvar html] return_headers html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
            if { [in $valid_response_codes $responsecode] } {
                # OK
                set response_body [encoding convertfrom [qc::http_encoding $return_headers $html] $html]
                if { !$response_headers && !$response_code } {
                    # Only return the response body.
                    return $response_body
                } else {
                    # User has requested response headers and/or code alongside the response body.
                    set response [dict create \
                                      body $response_body \
                                     ]

                    if { $response_code } {
                        dict set response code $responsecode
                    }

                    if { $response_headers } {
                        dict set response headers $return_headers
                    }

                    return $response
                }
            } else {
                switch $responsecode {                    
                    404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
                    500 {return -code error -errorcode CURL "SERVER ERROR $url"}
                    default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url"}
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

proc qc::http_header {name value} {
    #| Return http header. 
    #| Raise an error if the value of the http header contains newline characters.
    if { [regexp {\n} $value] } {
        error "The value of http header, \"$name: $value\", contains newline characters."
    }
    return "$name: $value"
}

proc qc::http_put {args} {
    # usage http_put \
    #   ?-valid_response_codes 200? \
    #   ?-header 0? \
    #   ?-timeout timeout? \
    #   ?-infile infile? \
    #   ?-data data? \
    #   ?-headers {name value name value ...}? \
    #   url
    args $args \
        -header 0 \
        -timeout 60 \
        -valid_response_codes [list 200] \
        -sslversion tlsv1 \
        -headers {} \
        -infile ? \
        -data ? \
        -response_code false \
        -response_headers false \
        url 

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }

    if { [info exists data] && [info exists infile]} {
        error "qc::http:put must have only 1 of -data or -infile specified"
    } elseif { [info exists infile] } {
        dict2vars \
                [qc::http_curl \
                    -header $header \
                    -upload 1 \
                    -infile $infile \
                    -headervar return_headers \
                    -url $url \
                    -sslverifypeer 0 \
                    -sslverifyhost 0 \
                    -timeout $timeout \
                    -sslversion $sslversion \
                    -followlocation 1 \
                    -httpheader $httpheaders \
                    -bodyvar html \
                ] \
                return_headers \
                html \
                responsecode \
                curlErrorNumber

    } elseif { [info exists data] }  {
        dict2vars \
            [qc::http_curl \
                -header $header \
                -customrequest PUT \
                -postfields $data \
                -headervar return_headers \
                -url $url \
                -sslverifypeer 0 \
                -sslverifyhost 0 \
                -timeout $timeout \
                -sslversion $sslversion \
                -followlocation 1 \
                -httpheader $httpheaders \
                -bodyvar html \
            ] \
            return_headers \
            html \
            responsecode \
            curlErrorNumber

    } else {
        error "qc::http:put must have 1 of -data or -infile specified"
    }

    switch $curlErrorNumber {
	0 {
            if { $responsecode in $valid_response_codes } {
                set response_body [encoding convertfrom [qc::http_encoding $return_headers $html] $html]
                if { !$response_headers && !$response_code } {
                    # Only return the response body.
                    return $response_body
                } else {
                    # User has requested response headers and/or code alongside the response body.
                    set response [dict create \
                                      body $response_body \
                                     ]

                    if { $response_code } {
                        dict set response code $responsecode
                    }

                    if { $response_headers } {
                        dict set response headers $return_headers
                    }

                    return $response
                }
            }
	    switch $responsecode {
		404 {
                    return \
                        -code error \
                        -errorcode CURL \
                        "URL NOT FOUND $url"
                    }
		500 {
                    return \
                        -code error \
                        -errorcode CURL \
                        "SERVER ERROR $url"
                }
		default {
                    return \
                        -code error \
                        -errorcode CURL \
                        "RESPONSE $responsecode while contacting $url"
                }
	    }
	}
	28 {
	    return \
                -code error \
                -errorcode TIMEOUT \
                "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return \
                -code error \
                -errorcode CURL \
                [curl::easystrerror $curlErrorNumber]
	}
    }
}

proc qc::http_patch {args} {
    # usage http_patch \
    #   ?-valid_response_codes 200? \
    #   ?-header 0? \
    #   ?-timeout timeout? \
    #   ?-data data? \
    #   ?-headers {name value name value ...}? \
    #   url
    args $args \
        -header 0 \
        -timeout 60 \
        -valid_response_codes [list 200] \
        -sslversion tlsv1 \
        -headers {} \
        -data ? \
        -response_headers false \
        -response_code false \
        url

    set httpheaders {}
    foreach {name value} $headers {
        lappend httpheaders [qc::http_header $name $value]
    }

    if { ![info exists data] } {
        error "qc::http:put must have -data specified"
    } else {
        dict2vars \
            [qc::http_curl \
                -header $header \
                -customrequest PATCH \
                -postfields $data \
                -headervar return_headers \
                -url $url \
                -sslverifypeer 0 \
                -sslverifyhost 0 \
                -timeout $timeout \
                -sslversion $sslversion \
                -followlocation 1 \
                -httpheader $httpheaders \
                -bodyvar html \
            ] \
            return_headers \
            html \
            responsecode \
            curlErrorNumber

    }

    switch $curlErrorNumber {
        0 {
            if { $responsecode in $valid_response_codes } {
                set response_body [encoding convertfrom \
                                       [qc::http_encoding $return_headers $html] \
                                       $html]

                if { !$response_headers && !$response_code } {
                    return $response_body
                } else {
                    set response [dict create \
                                      body $response_body \
                                     ]

                    if { $response_code } {
                        dict set response code $responsecode
                    }

                    if { $response_headers } {
                        dict set response headers $return_headers
                    }

                    return $response
                }
            }
            switch $responsecode {
                404 {
                    return \
                        -code error \
                        -errorcode CURL \
                        "URL NOT FOUND $url"
                    }
                500 {
                    return \
                        -code error \
                        -errorcode CURL \
                        "SERVER ERROR $url"
                }
                default {
                    return \
                        -code error \
                        -errorcode CURL \
                        "RESPONSE $responsecode while contacting $url"
                }
            }
        }
        28 {
            return \
                -code error \
                -errorcode TIMEOUT \
                "Timeout after $timeout seconds trying to contact $url"
        }
        default {
            return \
                -code error \
                -errorcode CURL \
                [curl::easystrerror $curlErrorNumber]
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
        "iso-ir-6" -
        "ansi_x3.4-1968" -
        "ansi_x3.4-1986" -
        "iso_646.irv:1991" -
        "ascii" -
        "iso646-us" -
        "us-ascii" -
        "us" -
        "ibm367" -
        "cp367" -
        "csASCII" {return ascii}
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
        
        "windows-1250" -
        "cp1250"      {return cp1250}
        
        "windows-1253" -
        "cp1253"      {return cp1253}

        "windows-1254" -
        "cp1254"      {return cp1254}

        "windows-1255" -
        "cp1255"      {return cp1255}

        "windows-1256" -
        "cp1256"      {return cp1256}

        "windows-1257" -
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

        "gbk" {return cp936}

        "iso-ir-149" -
        "ks_c_5601-1987" -
        "ks_c_5601-1989" -
        "ks_c_5601" -
        "korean" -
        "csksc56011987" {return ksc5601}
        
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
    args $args -headers {} -timeout 60 -useragent ? url
    default useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.7) Gecko/20060909 FreeBSD/i386 Firefox/1.5.0.7"
    #
    
    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }

    dict2vars [qc::http_curl -nobody 1 -headervar headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1 -httpheader $httpheaders] headers responsecode curlErrorNumber

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

proc qc::http_exists {args} {
    #| Test if an URL returns a valid response
    # usage http_head ?-timeout timeout? ?-useragent useragent? url
    args $args -timeout 60 -useragent ? -valid_response_codes {100 200} url
    default useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.7) Gecko/20060909 FreeBSD/i386 Firefox/1.5.0.7"
    #
    dict2vars [qc::http_curl  -nobody 1 -headervar headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1] responsecode curlErrorNumber

    if { [in $valid_response_codes $responsecode] } {
	return true
    } else {
	return false
    }
}

proc qc::http_save {args} {
    #| Save the HTTP response to a file.
    args $args \
        -timeout 60 \
        -headers {} \
        -sslversion tlsv1 \
        -sslverifypeer 0 \
        -sslverifyhost 0 \
        -return_headers_var {} \
        -- \
        url \
        file

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders [qc::http_header $name $value]
    }

    dict2vars [qc::http_curl \
                -httpheader $httpheaders \
                -headervar return_headers \
                -timeout $timeout \
                -url $url \
                -file $file \
                -sslverifypeer $sslverifypeer \
                -sslverifyhost $sslverifyhost \
                -sslversion $sslversion \
              ] return_headers responsecode curlErrorNumber

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
            if { $return_headers_var ne {} } {
                upset 1 $return_headers_var $return_headers
            }
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
	lappend httpheaders [qc::http_header $name $value]
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

proc qc::http_url_resolve {args} {
    #| Return resolved url after following redirects
    #
    # Misconfigured clickthrough servers may not redirect HEAD requests so always request a body by default
    args $args -timeout 60 -sslversion tlsv1 -nobody 0 -- url

    dict2vars [qc::http_curl -url $url -sslversion $sslversion -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1 -nobody $nobody -infovar info -bodyvar html] info curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    # OK
	    return [dict get $info effectiveurl]
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }    
}

proc qc::http_header_get {header_name} {
    #| Returns the value for the given header.
    set headers_set_id [ns_conn headers]
    if { [ns_set ifind $headers_set_id $header_name] == -1 } {
        return ""
    } elseif { [string tolower $header_name] in [qc::http_headers_with_value_as_list] } {
        # Header may appear more than once so get all values for the header.
        set header_values {}
        for {set i 0} {$i < [ns_set size $headers_set_id]} {incr i} {
            if { [string equal -nocase [ns_set key $headers_set_id $i] $header_name] } {
                lappend header_values [ns_set value $headers_set_id $i]
            }
        }
        
        return [join $header_values ","]
    } else {
        return [ns_set iget $headers_set_id $header_name]
    }
}

proc qc::http_header_parse {header_name header_value} {
    #| Parses the given header value string into a Tcl structure that is a list of dicts.
    #| E.G. qc::http_header_parse "application/json;q=0.9,text/xml,text/plain;q=0.8"
    #|      -> {token application/json params {q 0.9}} {token text/xml params {}} {token text/plain params {q 0.8}}
    
    # TODO: Header comments.
    # TODO: Quoted strings.
    # TODO: Validation of tokens and params?

    # Get the elements of the header value
    if { [string tolower $header_name] in [qc::http_headers_with_value_as_list] } {
        set elements [qc::map {x {string trim $x}} [split $header_value ","]]
    } else {
        # TODO: Handle other delimiters for other headers.
        set elements [list $header_value]
    }
    
    set result {}
    foreach element $elements {
        set element_dict [dict create]
        # Parse all params for this element
        set params [qc::map {x {string trim $x}} [split $element ";"]]
        # Most elements begin with a token but there are special cases where the element only consists of params.
        if { [string tolower $header_name] in [list "cookie" "set-cookie" "strict-transport-security"] } {
            set token ""
        } else {
            set token [lindex $params 0]
            set params [lrange $params 1 end]
        }

        # Parse param names and their values
        set param_dict [dict create]
        foreach param $params {
            set list [qc::map {x {string trim $x}} [split $param "="]]
            set name [lindex $list 0]
            if { [llength $list]  > 1 } {
                set value [lindex $list 1]
            } else {
                set value ""
            }
            dict set param_dict $name $value
        }
        dict set element_dict token $token
        dict set element_dict params $param_dict
        lappend result $element_dict
    }

    return $result
}

proc qc::http_headers_with_value_as_list {} {
    #| A list of headers whose values are defined as a comma separated list.
    set headers {}
    lappend headers accept
    lappend headers accept-charset
    lappend headers accept-encoding
    lappend headers accept-language
    lappend headers accept-ranges
    lappend headers allow
    lappend headers cache-control
    lappend headers connection
    lappend headers content-encoding
    lappend headers content-language
    lappend headers expect
    lappend headers if-match
    lappend headers if-none-match
    lappend headers pragma
    lappend headers proxy-authenticate
    lappend headers te
    lappend headers trailer
    lappend headers upgrade
    lappend headers vary
    lappend headers via
    lappend headers warning
    lappend headers www-authenticate
    lappend headers x-forwarded-for
    return $headers
}

proc qc::http_header_sort_values_by_weight {values} {
    #| Sorts the header values by weight.
    if { [llength $values] == 0 } {
        return [list]
    }
    set sorted [list [lindex $values 0]]
    foreach value [lrange $values 1 end] {
        if { [dict exists $value params q] } {
            set weight [dict get $value params q]
        } else {
            set weight 1
        }
        set inserted false
        for { set i 0 } { $i < [llength $sorted] } { incr i } {
            set dict [lindex $sorted $i]
            if { [dict exists $dict params q] } {
                set sorted_weight [dict get $dict params q]
            } else {
                set sorted_weight 1
            }
            if { $weight > $sorted_weight } {
                set sorted [linsert $sorted $i $value]
                set inserted true
                break
            }
        }
        
        if { ! $inserted } {
            set sorted [linsert $sorted end $value]
        }
    }
    return $sorted
}

proc qc::http_accept_header_best_mime_type {available_media} {
    #| Returns a mime type from the available media list that is the best match
    #| for the preferences of the Accept header.
    #| If any mime type will suffice then "*/*" is returned.
    #| Returns the empty string if no sufficient match is found.
    
    # TODO specificity.
    set sorted [qc::http_header_sort_values_by_weight [qc::http_header_parse Accept [qc::http_header_get Accept]]]
    if { [llength $sorted] == 0 } {
        return "*/*"
    }
    foreach dict $sorted {
        lassign [split [dict get $dict token] "/"] type subtype
        # If best mime type is "*/*" then let caller know so that they can choose the most suitable type.
        if { $type eq "*" && $subtype eq "*" } {
            return "$type/$subtype"
        }
        foreach item $available_media {
            lassign [split $item "/"] available_type available_subtype
            if { [string match -nocase $type $available_type] && [string match -nocase $subtype $available_subtype] } {
                return $item
            }
        }
    }
    return ""
}

proc qc::http_content_negotiate {available_mime_types} {
    #| Try to find an acceptable mime type to respond to the client with.
    #| Returns a mime type if an acceptable one was found otherwise the empty string.
    set result "" 
    set suffix [string range [file extension [qc::conn_path]] 1 end]
    # Prioritise suffix type because it is a direct request for a resource of that type.
    if { $suffix ne "" } {
        # Check if the suffix type is available and that the client accepts it.
        foreach mime_type $available_mime_types {
            lassign [split $mime_type "/"] type subtype
            if { [string match -nocase $subtype $suffix] && [qc::http_accept_header_best_mime_type [list $mime_type]] ne "" } {
                set result $mime_type
                break
            }
        }
    }

    if { $result eq "" } {
        set result [qc::http_accept_header_best_mime_type $available_mime_types]
    }

    return $result
}
