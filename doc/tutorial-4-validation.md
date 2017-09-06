Tutorial 4: Validation and the data model
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through implementing http request validation, filter validation and checking data against our data model.

-----
## Setting up a conn marshal

Remove the following line from your init.tcl file:

```
ns_register_proc GET /* qc::handler_restful
```

Add the following code (copied from [Setting Up a Connection Marshal and Request Handlers](doc/setting-up.md)):

```tcl
if {![nsv_exists . init]} {

    foreach http_method [list GET POST HEAD] {
        ns_register_filter preauth $http_method /* qc::filter_http_request_validate
        ns_register_filter postauth $http_method /* qc::filter_validate
        ns_register_proc $http_method /* conn_marshal
    }

    qc::anonymous_session_id

    nsv_set . init done
}

proc conn_marshal {} {
    #| Handles requests
    try {
        if {[qc::conn_open]} {
            qc::handler_restful
        }

        if {[qc::conn_open]} {
            qc::return2client code 404 html "Not Found"
        }
    } on error [list error_message options] {
        return [qc::error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]]
    }
}
```

-----
## Adding the validation rules

In a psql shell, run the following:

```
ALTER TABLE form
  ADD COLUMN first_name plain_string,
  ADD COLUMN last_name plain_string
```

-----
## Validating our form data

Remove the existing handler for `ns_register_proc POST /form_process` from `init.tcl` and replace with the following:

```
register POST /form_process {
    form.first_name
    form.last_name
} {
    #| Handle form submission via POST

    nsv_set _form first_name $first_name
    nsv_set _form last_name $last_name

    ns_returnredirect form_results.html
}
```

Adding a valid first and last name to the form will submit correctly, adding a value that does not comply with the `plain_string` rule (e.g a string containing an HTML tag) will result in an error message being displayed.
