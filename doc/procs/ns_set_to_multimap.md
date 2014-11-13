qc::ns_set_to_multimap
======================

part of [Docs](../index.md)

Usage
-----
`
        qc::ns_set_to_multimap set_id
    `

Description
-----------
Take an ns_set with id $set_id from caller return a multimap of key pairs.

Examples
--------
```tcl

1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
2> qc::ns_set_to_multimap  $set_id
from me@here.com to you@there.com msg {Get off my land.} to andyou@there.com to youtoo@there.com
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"