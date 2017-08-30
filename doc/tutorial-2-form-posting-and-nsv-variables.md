Tutorial 2: An introduction to forms
========
part of [Qcode Documentation](index.md)

-----
### Introduction

In this section we look at creating a form, handling the form post and implementing temporary storage using NSV variables.


-----
### Creating a simple HTML form

In the `init.tcl` file we created in the first tutorial, add the following code below the "Hello World" proc.

```tcl
register GET /form.html {} {
    #| Build and return form HTML

    set html {
	<html>
	  <body>
	    <form method="POST" action="form_process">
	      First Name <input name="first_name" type="text" />
	      Last Name  <input name="last_name" type="text" />
	      <input type="submit" name="submit" value="submit" />
	    </form>
	  </body>
	</html>
    }
    
    return $html
}
```

-----
### Handling the form post

Add the code below to the `init.tcl` file.  When the form is submitted from "form.html" the action will look for "form_process" and find our proc.

```tcl
ns_register_proc POST /form_process form_process

proc form_process {} {
    set first_name [qc::form_var_get first_name]
    set last_name [qc::form_var_get last_name]

    nsv_set _form first_name $first_name
    nsv_set _form last_name $last_name

    qc::return2client html "Form Submitted"
}
```

-----
### Viewing the stored variables

Once the form has been filled out and submitted, we can then reference the values entered by the user.

```tcl
register GET /form_results.html {} {
    set first_name [nsv_get _form first_name]
    set last_name [nsv_get _form last_name]
    
    return "Hello $first_name $last_name"
}
```
