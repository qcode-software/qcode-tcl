qc::ns_set_to_vars
==================

part of [Docs](.)

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

1&gt; set set_id [ns_set create this_set from me@here.com to you@there.com msg  &quot;Get off my land.&quot;]
d3
2&gt; qc::ns_set_to_vars $set_id

3&gt; set to
you@there.com
4&gt; set from
me@here.com
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"