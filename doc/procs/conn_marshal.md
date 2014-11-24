qc::conn_marshal
================

part of [Docs](../index.md)

Usage
-----
`qc::conn_marshal ?error_handler? ?namespace?`

Description
-----------
Look for a proc with a leading slash like /foo.html that matches the incoming request url.<br/>If found call the proc with values from form variables that match the proc's argument names.<br/>The request suffix is used to decide which error handler to use.<br/>If no matching proc exists then try to return a file or a 404 not found.

Examples
--------
```tcl

# We can use ns_register_proc to get conn_marshal to handle .html requests with
% ns_register_proc GET  /*.html conn_marshal
% ns_register_proc POST /*.html conn_marshal
% ns_register_proc HEAD /*.html conn_marshal

# If we then create a proc
proc /foo.html {greeting name} {
    return "You said $greeting $name"
}
# a request for /foo.html?greeting=Hello&name=John would result in a call to 
/foo.html Hello John
# and return "You said Hello John"

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"