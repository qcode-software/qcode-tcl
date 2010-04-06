proc qc::http_post {args} {
    # usage http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-data data? url ?name value? ?name value?
    args $args -timeout 60 -encoding utf-8 -content-type ? -soapaction ? -data ? url args

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
    if { [info exists content-type] } {
	lappend httpheaders "Content-Type: ${content-type}"
    }

    if { [info exists soapaction] } {
	lappend httpheaders "SOAPAction: $soapaction"
    }

    set curlHandle [curl::init]
    $curlHandle configure -url $url -sslverifypeer 0 -sslverifyhost 0 \
        -timeout $timeout -bodyvar html -post 1 -httpheader $httpheaders -postfields $data
    catch { $curlHandle perform } curlErrorNumber
    set responsecode [$curlHandle getinfo responsecode]
    $curlHandle cleanup
    switch $responsecode {
	100 {
	    ns_log Notice "HTTP/1.1 100 $html"
	}
	200 {
	    # OK
	}
	404 {return -code error -errorcode CURL "URL NOT FOUND $url"}
	500 {return -code error -errorcode CURL "SERVER ERROR $url $html"}
	default {return -code error -errorcode CURL "RESPONSE $responsecode while contacting $url $html"}
    }
    switch $curlErrorNumber {
	0 {
	    # OK
	    return $html
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
    # usage http_get ?-timeout timeout? ?-useragent useragent? url
    args $args -timeout 60 -useragent ? url
    default useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.7) Gecko/20060909 FreeBSD/i386 Firefox/1.5.0.7"
    #
    set curlHandle [curl::init]
    $curlHandle configure -url $url -sslverifypeer 0 -sslverifyhost 0 -timeout $timeout -followlocation 1 -bodyvar html
    catch { $curlHandle perform } curlErrorNumber
    set responsecode [$curlHandle getinfo responsecode]
    $curlHandle cleanup
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
	    return $html
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error -errorcode CURL [curl::easystrerror $curlErrorNumber]
	}
    }
}

proc qc::http_save {url file} {
    set curlHandle [curl::init]
    $curlHandle configure -url $url -file $file -sslverifypeer 0 -sslverifyhost 0
    catch { $curlHandle perform } curlErrorNumber
    set responsecode [$curlHandle getinfo responsecode]
    $curlHandle cleanup
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
