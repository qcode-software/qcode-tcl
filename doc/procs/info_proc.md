qc::info_proc
=============

part of [Docs](../index.md)

Usage
-----
`
        qc::info_proc proc_name
    `

Description
-----------
Return the Tcl source code definition of a Tcl proc.

Examples
--------
```tcl

% qc::info_proc trim
proc qc::trim {string} {
    #| Removes and leading or trailing white space.
    return [string trim $string]
}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"