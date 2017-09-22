Tutorial 4: Validation and the POST handler
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through preparing the database for validation using validate2model, using the register POST handler and specifying arguments for the POST handler.

-----
## Adding the validation rules

In a psql shell, run the following:

```
ALTER TABLE form
  ADD COLUMN first_name plain_string,
  ADD COLUMN last_name plain_string
```

This will add the parameters `first_name` and `last_name` to the `form` table and define them as the `plain_string` custom data type as implemented by the Qcode tcl DB init procedure ([See Supported Data Types](doc/supported-data-types.md)).

When using `qc::handler_restful` the ensemble `qc::handlers call` is called. This uses the [validate2model](doc/validation.md) library.

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

This changes our code from using `ns_register_proc` to using `handler_restful` to register the `form_process` procedure.  This procedure takes two arguments, `first_name` and `last_name` and checks them against the database using validate2model, doing away with the requirement to use `form_get_var`.

Qcode tcl will then will make these form variables available as local tcl variables in the proc, which then continues to register them as naviserver variables as before.

Once the changes above are complete, adding a valid first and last name to the form will submit correctly.  Adding a value that does not comply with the `plain_string` rule (e.g a string containing an HTML tag) will result in an error message being displayed.
