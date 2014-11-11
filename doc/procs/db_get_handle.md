qc::db_get_handle
=================

part of [Database API](../db.md)

Usage
-----
`qc::db_get_handle ?poolname?`

Description
-----------
Return a database handle.
    Keep one handle per pool for current thread in a thread global variable.
    At thread exit AOLserver will release the db handle.

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"