package provide qcode 1.16
package require doc
namespace eval qc {}

proc qc::soap_template {xml method {namespace ""} } {
    sset soap {<?xml version="1.0"?>
	<soap:Envelope
	xmlns:soap="http://www.w3.org/2001/12/soap-envelope"
	soap:encodingStyle="http://www.w3.org/2001/12/soap-encoding">
	<soap:Body>
	<ns:$method xmlns:ns="$namespace">
	$xml
	</ns:$method>
	</soap:Body>
	</soap:Envelope>
    }
    return $soap
}
