package provide qcode 1.10
package require doc
namespace eval qc {}

proc qc::ftp_get {args} {
    # usage ftp_get ?-timeout timeout? ?-userpwd user:password? url
    args $args -timeout 60 -userpwd * url
    #
    set curlHandle [curl::init]
    $curlHandle configure -url $url -ftpuseepsv 0 -userpwd $userpwd -timeout $timeout -bodyvar html
    catch { $curlHandle perform } curlErrorNumber
    set responsecode [$curlHandle getinfo responsecode]
    $curlHandle cleanup
    switch $responsecode {
	226 { 
	    # OK 
	}
	default {return -code error "RESPONSE $responsecode while contacting $url"}
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
	    return -code error [curl::easystrerror $curlErrorNumber]
	}
    }
}
