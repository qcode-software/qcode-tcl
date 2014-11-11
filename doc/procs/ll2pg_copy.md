qc::ll2pg_copy
==============

part of [Database API](../db.md)

Usage
-----
`ll2pg_copy ll`

Description
-----------
Convert a list of lists data structure into the format accepted by postgresql's copy statements

Examples
--------
```tcl

% qc::ll2pg_copy [list [Daniel Clark daniel@qcode.co.uk] [list Bernhard "van Woerden" bernhard@qcode.co.uk] [list David Osborne david@qcode.co.uk]]
Daniel    Clark    daniel@qcode.co.uk
    Bernhard    van Woerden    bernhard@qcode.co.uk
    David    Osborne    david@qcode.co.uk
    
    %

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"