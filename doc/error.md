Error Handling
======================

[qc::error_handler](doc/procs/error_handler.md)
--------------------------

Errors are classified by the errorCode returned and [qc::error_handler](doc/procs/error_handler.md) will return a suitable message and code to the client based upon the error code.

Currently supported are the following codes:
* USER
* PERM
* AUTH
* NOT_FOUND
* BAD_REQUEST

### USER Errors
The error message will be returned to the customer normally as the result of invalid input.

### PERM Errors
The user does not have permision on the resource.
An indication of the missing permission is given.

### AUTH Errors
Could not authenticate who the user is.

### NOT_FOUND Errors
The requested resource could not be found.

### BAD_REQUEST
The request from the client wasn't well formed.

### Bugs
If the errorCode does not classify the error as one of the above then it is a bug or other unexpected runtime error.
We can report back an [error_report](procs/error_report.md) back to the user or in a public application then a generic error message.
An email will be sent to the support email with details of the error report.

scheduled tasks
--------------------------


Each scheduled task needs to be wrapped in a [try](procs/try.md) clause with custom [error reporting](procs/error_report_no_conn.md).eg.
	
	   try {
		a_scheduled_task
	    } {
		email_send from nsd@localhost to support@domain.com subject $errorMessage html qc::error_report_no_conn
	    }
	