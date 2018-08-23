Form Variables
======================

Form variables are the name value pairs sent with HTTP GET requests or POST submissions.

### GET
URL Encoded string of name value pairs joined by = sign. 
`http://www.example.com/index.html?foo=Hello&baz=World`

### POST
http://www.jmarshall.com/easy/http/#postmethod
Data is send within the body of the POST.

Repeated Variable Names
--------------------------
Some HTML input elements like checkboxes 
	
	<input type="checkbox" name="email_id" value="1">
	<input type="checkbox" name="email_id" value="2">
	
can be used repeatedly within a form.

The GET or POST submission will repeat the same variable name
eg.
`email_id=1&email_id=2`

The Qcode library will convert this into a list of values so that 
	
	> qc::form_var_get email_id
	1 2
	
* [qc::form_var_get](procs/form_var_get.md)
* [qc::form_var_exists](procs/form_var_exists.md)
* [qc::form2vars](procs/form2vars.md)
* [qc::form2dict](procs/form2dict.md)
* [qc::form2url](procs/form2url.md)
* [qc::form_proc](procs/form_proc.md) - call a proc using corresponding form variables.

