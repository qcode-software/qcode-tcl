qc::ns_set_getall
=================

part of [Docs](../index.md)

Usage
-----
`
        qc::ns_set_getall set_id key
    `

Description
-----------
Take an ns_set with id $set_id from caller return all values for the key given

Examples
--------
```tcl

1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
d5
2> qc::ns_set_getall $set_id to
you@there.com andyou@there.com youtoo@there.com
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"