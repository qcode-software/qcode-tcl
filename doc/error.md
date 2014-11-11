# Error Handling

## qc::conn_marshal
If ns_register_proc is used to register the [qc::conn_marshal](procs/conn_marshal.md) to deal with incoming requests, errors are by default passed to [qc::error_handler](procs/error_handler.md).

Errors are classified by the global errorCode.

Currently used are:
* USER
* PERM
* AUTH

### USER Errors
The global errorMessage will be returned to the customer normally as the result of invalid input.

### PERM Errors
The user does not have permision on the resource.
An indication of the missing permission is given.

### AUTH Errors
Could not authenticate who the user is.

### Bugs
If the errorCode does not classify the error as one of the above then it is a bug or other unexpected runtime error.
We can report back an [error_report](procs/error_report.md) back to the user or in a public application then a generic error message.
An email will be sent to the support email with details of the error report.

## scheduled tasks

Each scheduled task needs to be wrapped in a [try](/qc/proc/qc::try) clause with custom [error reporting](procs/error_report_no_conn.md).eg.
	
	   try {
		a_scheduled_task
	    } {
		email_send from nsd@localhost to support@domain.com subject $errorMessage html qc::error_report_no_conn
	    }
	