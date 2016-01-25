Connection Handlers
======================

part of [Qcode Documentation](index.md)

* * *
Connection handlers are used to deal with requests. The qcode-tcl library provides 3 connection handlers for use in a connection marshal.

### [handler_restful]

This handler will deal with requests where there is a request handler registered for the requested path and method. It makes use of the [Handlers API] to determine if a request handler has been registered for the requested path. If there has been a request handler registered then that handler will be called and the result will be returned to the client which will close the connection.

The return types to the client will depend upon the method of the request:

* POST - the global response will be returned to the client as XML, JSON, or HTML depending upon the media types accepted by the client otherwise a code `406 Not Acceptable` with text description will be returned.
* GET  - HTML resulting from the call to the request handler will be returned to the client.

If there is no request handler registered for the requested path then `handler_restful` will not return to the client and the connection will remain open.

For more information regarding request handlers see [Handler and Path Registration].


### [handler_files]

This handler deals with file requests that haven't been resolved by fastpath. It will check for the existence of the requested file. If found then the file is added to the fastpath and the file is returned to the client which will close the connection.

If the requested file is not found then the handler will not return to the client and the connection will remain open.


### [handler_db_files]

This handler deals with files that are stored in the database and have yet to be cached on disk. If the request is for a file on the path `/image/` then the request is passed on to [`qc::image_handler`](procs/image_handler.md) or to [`qc::file_handler`](procs/file_handler.md) if the requested file is on the path `/file/`.

If the requested file is not on either of these paths then the handler will not return to the client and the connection will remain open.


Example
-------

An example of a very simple connection marshal using the above connection handlers:

```tcl
proc conn_marshal {} {
    #| Connection marshal to handle requests.
    if { ![qc::conn_served] } {
        qc::handler_restful
    }
    
    if { ![qc::conn_served] } {
        # The connection hasn't been served so the request wasn't handled by handler_restful.
        qc::handler_db_files
    }

    if { ![qc::conn_served] } {
        # The request wasn't handled by the previous handlers.
        qc::handler_files
    }

    if { ![qc::conn_served] } {
        # None of the handlers were able to handle the request.
        qc::return2client code 404 html "Not Found"
    }
}
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[Handler and Path Registration]: registration.md
[Handlers API]: handlers-api.md
[handler_restful]: procs/handler_restful.md
[handler_files]: procs/handler_files.md
[handler_db_files]: procs/handler_db_files.md
