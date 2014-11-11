qc::ns_set_to_dict
==================

part of [Docs](.)

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

1&gt; set set_id [ns_set create this_set from me@here.com to you@there.com msg  &quot;Get off my land.&quot;]
d3
2&gt; qc::ns_set_to_dict $set_id
from me@here.com to you@there.com msg {Get off my land.}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"