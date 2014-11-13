qc::ns_set_to_vars
==================

part of [Docs](../index.md)

Usage
-----
`
        qc::ns_set_to_vars set_id ?level?
    `

Description
-----------
Take an ns_set with id $set_id from caller and place variables in level $level.

Examples
--------
```tcl

1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land."]
d3
2> qc::ns_set_to_vars $set_id

3> set to
you@there.com
4> set from
me@here.com
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"