qc::ns_set_getall
=================

part of [Docs](.)

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

1&gt; set set_id [ns_set create this_set from me@here.com to you@there.com msg  &quot;Get off my land.&quot; to andyou@there.com to youtoo@there.com]
d5
2&gt; qc::ns_set_getall $set_id to
you@there.com andyou@there.com youtoo@there.com
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"