namespace eval qc {
    namespace export soap_template
}

proc qc::soap_template {xml method {namespace ""} } {
    #| SOAP template
    set soap {<?xml version="1.0"?>
	<soap:Envelope
	xmlns:soap="http://www.w3.org/2001/12/soap-envelope"
	soap:encodingStyle="http://www.w3.org/2001/12/soap-encoding">
	<soap:Body>
	${request_xml}
	</soap:Body>
	</soap:Envelope>
    }
    # Only define namespace prefix if a namespace has been passed

    if { $namespace ne "" } {
        set request_xml [qc::xml "ns:$method" \$xml [dict create xmlns:ns $namespace]]
    } else {
         set request_xml [qc::xml $method \$xml]
    }
    set request_xml [string map [list \$xml $xml] $request_xml]
      
    set soap [string map \
                    [list \${request_xml}  $request_xml] \
                    $soap \
             ]
    return $soap
}
