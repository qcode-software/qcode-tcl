qc::ns_set_to_dict
==================

part of [Docs](../index.md)

Usage
-----
`
        qc::ns_set_to_dict set_id
    `

Description
-----------
Take an ns_set with id $set_id from caller return a dict.

Examples
--------
```tcl

1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land."]
d3
2> qc::ns_set_to_dict $set_id
from me@here.com to you@there.com msg {Get off my land.}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"