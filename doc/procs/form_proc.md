qc::form_proc
=============

part of [Docs](../index.md)

Usage
-----
`qc::form_proc proc_name`

Description
-----------
Call proc_name using corresponding form variables
    if the last variable name is called args then it is filled with a dict containing name value
    pairs for the remaining form data.
    See <proc>conn_marshal</proc> for a way of using this.

Examples
--------
```tcl

# Lets say we have a proc called hello
proc hello {name message} {
    return_html "$name said $message"
}
# When handling a request for some-url.html?name=John&message=Hello%20World
% form_proc hello
John said Hello World
# equivalent to
% hello John "Hello World"
John said Hello World

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"