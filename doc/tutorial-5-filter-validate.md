Tutorial 5: Filter Validate
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through adding the `qc::filter_validate` custom validation handler. This filter is intended to be used prior to the request being handled to apply custom validation rules and ensure that invalid data isn't passed through to the request handler.

-----
## Registering the filter

`qc::filter_validate` should be registered with Naviserver during `preauth` or `postauth`, but not `trace`.

```
ns_register_filter postauth POST /* qc::filter_validate
```

-----
## Adding custom validation

`validate` is used to register a custom validation handler.

These handlers are used to set up custom validation for a request. They provide the ability to check data outside the data model, or validate some input differently.

Add the following proc to your init.tcl file:

```tcl
validate POST /form_process {
    first_name
    last_name
} {
    set messages [list]
    if {$first_name eq "JazzyB"} {
        lappend messages "Sorry, no DJs allowed"
    }
    if {$last_name eq "Windsor"} {
        lappend messages "No posh people please"
    }

    if {[llength $messages] > 0} {
        error [html_list $messages] {} USER
    }
}
```

This code ensures that user input complies with the custom validation rules and validates against the data model.

-----
## Error handling

When validation fails, `filter_validate` uses `qc::error_handler` as the default error handler. 

When an exception is raised, the Qcode-tcl error handler functions in different ways depending on the error code.  In the case of our code above (`error [html_list $messages] {} USER`) we define that data not matching the custom validation constraints is returned as a USER error, which is then formatted and presented to the user.
