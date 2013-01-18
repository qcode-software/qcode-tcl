# Form Variables

Form variables are the name value pairs sent with HTTP GET requests or POST submissions.

### GET
URL Encoded string of name value pairs joined by = sign. 
`http://www.example.com/index.html?foo=Hello&baz=World`

### POST
http://www.jmarshall.com/easy/http/#postmethod
Data is send within the body of the POST.

## Repeated Variable Names
Some HTML input elements like checkboxes 
	
	<input type="checkbox" name="email_id" value=="1">
	<input type="checkbox" name="email_id" value="2">
	
can be used repeatedly within a form.

The GET or POST submission will repeat the same variable name
eg.
`email_id=1&email_id=2`

The Qcode library will convert this into a list of values so that 
	
	> qc::form_var_get email_id
	1 2
	
* [qc::form_var_get](//qc/proc/qc::form_var_get)
* [qc::form_var_exists](//qc/proc/qc::form_var_exists)
* [qc::form2vars](//qc/proc/qc::form2vars)
* [qc::form2dict](//qc/proc/qc::form2dict)
* [qc::form2url](//qc/proc/qc::form2url)
* [qc::form_proc](//qc/proc/qc::form_proc) - call a proc using corresponding form variables.

