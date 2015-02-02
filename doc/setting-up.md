Setting Up
========
part of [Qcode Documentation](index.md)

* * *

This document will guide through pulling together features from the qcode-tcl library to set up request handling for Naviserver that will include validation of user input and authenticating users. 

### Naviserver Initialization
Firstly, we'll need to register filters and procs as well as creating an anonymous session but only when the server starts up. There are a few filters provided by the library and here we will use three of them:

* `qc::filter_http_request_validate` - to validate the HTTP request.
* `qc::filter_validate` - to validate user input.
* `qc::filter_authenticate` - to authenticate users.

For more information on filters see [Filters].

**Note:** if registering filters at the same stage it would seem that Naviserver calls them in the order that they were registered. This does not matter for the order of `qc::filter_validate` and `qc:filter_authenticate` as neither depends on the other. However, if registering another filter on `preauth` then we suggest that `qc::filter_http_request_validate` be registered first as there is little point in doing much work if the HTTP request is invalid.

```tcl
# use naviserver arrays to track initialising of server
if {![nsv_exists . init]} {

    # import the qcode-tcl library
    package require qcode
    
    # register on the three possible HTTP methods
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
    
    # update the naviserver array to show to initialisation has completed
    nsv_set . init done
}

```

### Connection Marshal
Next we want to create a connection marshal that will actually deal with the requests if they make it through validation and authentication. The following example is a very simple connection marshal that makes use of the connection handler [`qc::handler_restful`] provided by the library. Note that we registered this connection marshal above.

For more information see [Connection Handlers].

```tcl

proc conn_marshal {} {
    #| Handles requests
    try {
        if {qc::conn_open} {
            # a simple handler that tries to handle RESTful requests
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

### Request Handlers
Lastly, we need to register a request handler that will determine what happens to specific requests. Below is a handler for the request `GET /` that simply returns the string Hello World. [`qc::handler_restful`] makes use of the [Handlers API] to resolve requests to these request handlers and will also return the information to the client if the the request handler does not.

For more information on request handlers see [Handler and Path Registration].

```tcl

register GET / {} {
    #| Request handler for the request: GET /
    return "Hello World"
}

```

Alternatively the request handler may return directly to the client:

```tcl

register GET / {} {
    #| Request handler for the request: GET /
    qc::return2client html "Hello World"
}
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[Filters]: filters.md
[Connection Handlers]: connection-handlers.md
[`qc::handler_restful`]: connection-handlers.md#handler_restful.md
[Handlers API]: handlers-api.md
[Handler and Path Registration]: registration.md
