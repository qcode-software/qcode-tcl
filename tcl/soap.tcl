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
	<${ns_prefix}${method}${namespace}>
	$xml
	</${ns_prefix}${method}>
	</soap:Body>
	</soap:Envelope>
    }
    # Namespace prefix binding may not be empty.
    # If no namespace, do not use prefix
    set ns_prefix ""
    if { $namespace ne "" } {
        set namespace " xmlns:ns=\"$namespace\""
        set ns_prefix "ns:"
    }
    set soap [string map \
                    [list \${method}       $method \
                          \$xml            $xml \
                          \${namespace}    $namespace \
                          \${ns_prefix}    $ns_prefix \
                    ] \
                    $soap \
             ]
    return $soap
}
