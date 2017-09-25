Tutorial 4: Validation and the POST handler
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through using the database datamodel to validate user supplied data. This is implemented by validate2model, using the register POST handler and specifying arguments for the POST handler.

-----
## Adding the validation rules

In a psql shell, run the following:

```
ALTER TABLE form
  ADD COLUMN first_name plain_string,
  ADD COLUMN last_name plain_string
```

This will add columns `first_name` and `last_name` to the `form` table using the `plain_string` type ([See Supported Data Types](supported-data-types.md)).

When using `qc::handler_restful` the ensemble `qc::handlers call` is called. This uses the [validate2model](validation.md) library.

-----
## Registering a POST handler

Remove the following proc from your init.tcl file:

```tcl
ns_register_proc POST /form_process form_process

proc form_process {} {
    set first_name [qc::form_var_get first_name]
    set last_name [qc::form_var_get last_name]

    nsv_set _form first_name $first_name
    nsv_set _form last_name $last_name

    ns_returnredirect form_results.html
}
```

Replace this with the following code :

```tcl
ns_register_proc POST /* qc::handler_restful

register POST /form_process {
    first_name
    last_name
} {
    nsv_set _form first_name $first_name
    nsv_set _form last_name $last_name

    ns_returnredirect form_results.html
}
```

This changes our code from using `ns_register_proc` to using `handler_restful` to register the `form_process` url path.  This procedure takes two arguments, `first_name` and `last_name` and checks them against the database using validate2model, doing away with the requirement to use `form_get_var`.

Qcode tcl will make the form variables `first_name` and `last_name` available as local tcl variables when executing the code defined by the `register` url handler.

Once the changes above are complete, adding a valid first and last name to the form will submit correctly.  Adding a value that does not comply with the `plain_string` rule (e.g a string containing an HTML tag) will raise an error.
