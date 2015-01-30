Setting Up
========
part of [Qcode Documentation](index.md)

* * *

Firstly, we'll need to register filters and procs as well as creating an anonymous session when the server starts up.

```tcl

if {![nsv_exists . init]} {

    package require qcode
    package require try
       
    foreach http_method [list GET POST HEAD] {
        # Register filter that validates the HTTP request.
        ns_register_filter preauth $http_method /* qc::filter_http_request_validate
        # Register the filter that validates user input.
        ns_register_filter postauth $http_method /* qc::filter_validate
        # Register the filter that authenticates the user session and authenticity token.
        ns_register_filter postauth $http_method /* qc::filter_authenticate

        # Register a connection marshal that will deal with all requests.
        ns_register_proc $http_method /* conn_marshal
    }
  
    # Create anonymous session
    qc::anonymous_session_id
    
    nsv_set . init done
}

```


Next we want to create a connection marshal that will actually deal with the requests if they make it through validation and authentication. This is a very simple connection marshal.

```tcl

proc conn_marshal {} {
    # Deals with requests
    try {
        if {qc::conn_open} {
            qc::handler_restful
        }

        if {qc::conn_open} {
            # If the connection is still open then the request wasn't handled by handler_restful
            qc::return2client code 404 html "Not Found"
        }
    } on error [list error_message options] {
        return [qc::error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]]
    }
}

```


Finally, we need to register a handler that will determine what happens to specific requests. Below is a handler for the request `GET /` that simply returns the string Hello World. `qc::handler_restful` will deal with returning the information to the client.

```tcl

register GET / {} {
    return "Hello World"
}

```

* * *

Qcode Software Limited <http://www.qcode.co.uk>