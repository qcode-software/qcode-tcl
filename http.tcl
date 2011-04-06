proc qc::http_curl {args} {
    #| This is a wrapper for TclCurl which is not thread-safe when using some SSL libraries
    #| Uses ns_proxy to isolate.
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

    set handle [ns_proxy get myproxy]

    if { [dict exists $args -timeout] } {
	# The proxy may timeout first due to a dns lookup so double timeout
	set timeout [expr {[dict get $args -timeout]*1000*2}]
    } else {
	# default timeout 60seconds
	set timeout 60000
    }
    set dict [ns_proxy eval $handle $script $timeout]
    ns_proxy release $handle
    
    return $dict
}

proc qc::http_post {args} {
    # usage http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-accept accept? ?-authorization authorization? ?-data data? ?-valid_response_codes? url ?name value? ?name value?
    args $args -timeout 60 -sslversion sslv3 -encoding utf-8 -content-type ? -soapaction ? -accept ? -authorization ? -data ? -valid_response_codes {100 200} url args

    # args is name value name value ... list
    if { [llength $args]==1 } {set args [lindex $args 0]}
    
    if { ![info exists data]} {
	set pairs {}
	foreach {name value} $args {
	    lappend pairs "[ns_urlencode -charset $encoding $name]=[ns_urlencode -charset $encoding $value]"
	}
	set data [join $pairs &]

    }
    set httpheaders {}
    if { [info exists authorization] } {
	lappend httpheaders "Authorization: $authorization"
    }

    if { [info exists content-type] } {
	lappend httpheaders "Content-Type: ${content-type}"
    }

    if { [info exists accept] } {
	lappend httpheaders "Accept: $accept"
    }

    if { [info exists soapaction] } {
	lappend httpheaders "SOAPAction: $soapaction"
    }

    dict2vars [qc::http_curl -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0  -timeout $timeout -sslversion $sslversion -bodyvar html -post 1 -httpheader $httpheaders -postfields $data] html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    if { [in $valid_response_codes $responsecode] } {
		return [encoding convertfrom [qc::http_header_encoding [array get return_headers]] $html]
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
    # usage http_get ?-timeout timeout? ?-headers {name value name value ...}? url
    args $args -timeout 60 -sslversion sslv3 -headers {} url

    set httpheaders {}
    foreach {name value} $headers {
	lappend httpheaders "$name: $value"
    }
   
    dict2vars [qc::http_curl  -headervar return_headers -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -sslversion $sslversion -followlocation 1 -httpheader $httpheaders  -bodyvar html] html responsecode curlErrorNumber

    switch $curlErrorNumber {
	0 {
	    switch $responsecode {
		200 { 
		    # OK
		    return [encoding convertfrom [qc::http_header_encoding [array get return_headers]] $html] 
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

proc qc::http_header_encoding { dict } {
    array set return_headers $dict
    foreach key {Content-Type content-type} {
        if { [info exists return_headers($key)] && [regexp -nocase {.*;.*charset=(.*)} $return_headers($key) -> charset] } {
	    return [IANAEncoding2TclEncoding [string trim $charset]]
        }
    }
    # Defaults to iso-8859-1 as per RFC2616
    # Misspelt in TCL
    return "iso8859-1"
}

#----------------------------------------------------------------------------
#   IANAEncoding2TclEncoding
#   From v0.82 tDom lib/tdom.tcl
#----------------------------------------------------------------------------

proc IANAEncoding2TclEncoding {IANAName} {
    
    switch [string tolower $IANAName] {
        "us-ascii"    {return ascii}
        "utf-8"       {return utf-8}
        "utf-16"      {return unicode}; # not sure about this
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

proc qc::http_exists {args} {
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

proc qc::http_save {url file} {
    dict2vars [qc::http_curl -url $url -file $file -sslverifypeer 0 -sslverifyhost 0] responsecode curlErrorNumber
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
