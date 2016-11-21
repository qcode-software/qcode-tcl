Error Handling
======================

[qc::error_handler](procs/error_handler.md)
--------------------------

Errors are classified by the error code. [qc::error_handler](procs/error_handler.md) will return a suitable message and code to the client based upon the error code. The response content type is determined through content negotiation however if a suitable response content type cannot be negotiated then a code 406 (Not Acceptable) will be returned along with a plain text message describing available content types.

Currently supported response content types:
* XML
* JSON
* HTML

## Error Codes

### USER
**HTTP Response Code:** 200

The error message will be returned to the customer normally as the result of invalid input.

### PERM
**HTTP Response Code:** 401

The user does not have permision on the resource.
An indication of the missing permission is given.

### AUTH
**HTTP Response Code:** 401

Could not authenticate who the user is.

### NOT_FOUND
**HTTP Response Code:** 404

The requested resource could not be found.

### BAD_REQUEST
**HTTP Response Code:** 400

The request from the client wasn't well formed.

### Default Behaviour
**HTTP Response Code:** 500

If the error code is not one of the above then it is a bug or other unexpected runtime error. In such cases the user will be sent a message to let them know that an internal server error occurred. The [error report](procs/error_report.md) will then be sent via email to the support email address if one exists.

Scheduled Tasks
--------------------------


Each scheduled task needs to be wrapped in a [try](procs/try.md) clause with custom [error reporting](procs/error_report_no_conn.md). E.g.

```tcl
try {
    a_scheduled_task
} on error [list message options] {
    email_send \
        from nsd@localhost \
        to support@domain.com \
        subject $message \
        html [qc::error_report_no_conn $message [dict get $options -errorinfo] [dict get $options -errorcode]]
}
```	
