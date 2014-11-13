qc::ns_set_keys
===============

part of [Docs](../index.md)

Usage
-----
`
        qc::ns_set_keys set_id 
    `

Description
-----------
Take an ns_set with id $set_id from caller return all keys

Examples
--------
```tcl

1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
d1
2> qc::ns_set_keys $set_id
from to msg to to
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"