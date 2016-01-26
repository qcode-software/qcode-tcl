Setting Up
========
part of [Qcode Documentation](index.md)

* * *

This guide will demonstrate how to use the qcode-tcl library with Naviserver to handle incoming requests, perform validation of user input, and perform user authentication.

### Naviserver Initialization
Firstly, we'll need to register filters and procs and ensure that the anonymous session has been created. There are a few filters provided by the library and here we will use three of them:

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
        if {[qc::conn_open]} {
            # a simple handler that tries to handle RESTful requests
            qc::handler_restful
        }

        if {[qc::conn_open]} {
            # If the connection is still open then the request wasn't handled by handler_restful
            qc::return2client code 404 html "Not Found"
        }
    } on error [list error_message options] {
        return [qc::error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]]
    }
}

```

### Request Handlers
Lastly, we need to register a request handler that will determine what happens to specific requests. Below is a handler for the request `GET /` that simply returns the string "Hello World". [`qc::handler_restful`] makes use of the [Handlers API] to resolve requests to these request handlers and will also return the information to the client if the the request handler does not.

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

An example of using the [Connection Response] API:

```tcl

register POST /entry {entry_title entry_content} {
    #| Request handler for creating a new blog entry
    # we don't need to validate the data because by the time this request handler is called qc::filter_validate has done the validation for us
    set entry_id [entry_create $post_title $entry_content]
    # use the Connection Response API to redirect the client to the new entry URL.
    qc::actions redirect [url "/entry/$entry_id"]
}
```

Sometimes the data might be too complex to be validated entirely from the data model. Using [validation handlers] allows you to manually validate data. Remember to set up the [Connection Response].

Note that the method, path, and arguments are the same as the request handler above. This is what ties this validation handler to the request handler above.

```tcl

validate POST /entry {entry_title entry_content} {
    #| Validation handler for new blog entries.
    set valid [qc::is safe_markdown $entry_content]
    if { ! $valid } {
        # find out what was wrong with the content to give better feedback to the client
        set reasons [error_report $entry_content]
        # update the response
        qc::record invalid entry_content $entry_content $reasons
    } else {
        qc::record valid entry_content $entry_content ""
    }
    return $valid
}
```

Using [colon variables] can generalise requests so new handlers aren't required for very similar requests. For example the requests for blog entries only differs by the `entry_id` (`GET /entry/1` `GET /entry/2` etc.):

```tcl

register GET /entry/:entry_id {entry_id} {
    #| Request handler for getting specific blog entries.
    return [entries_get $entry_id]
}
```

### Data Model Dependencies

Various aspects of this implementation rely upon a data model being present with certain tables in place. In particular, see `qc::filter_validate` and `qc::filter_authenticate` within the [Data Model Dependencies] documentation to set up the data model for this guide.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[Filters]: filters.md
[Connection Handlers]: connection-handlers.md
[`qc::handler_restful`]: connection-handlers.md#handler_restful.md
[Handlers API]: handlers-api.md
[Handler and Path Registration]: registration.md
[Connection Response]: connection-response.md
[colon variables]: registration.md#paths-with-variable-elements
[validation handlers]: registration.md#validate
[Data Model Dependencies]: data-model-dependencies.md
