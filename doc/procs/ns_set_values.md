qc::ns_set_values
=================

part of [Docs](.)

Usage
-----
`
        qc::ns_set_values { set_id } {
	}
	Examples {
	    1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
	    d1
	    2>  qc::ns_set_values $set_id
	    me@here.com you@there.com {Get off my land.} andyou@there.com youtoo@there.com
	}
    `

Description
-----------
Take an ns_set with id $set_id from caller return all values

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"