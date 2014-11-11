qc::debug
=========

part of [Docs](.)

Usage
-----
`
        qc::debug message
    `

Description
-----------
If running in naviserver and debugging is switched on then write message to nsd log.
        Otherwise write message to stdout.
        Filter message by masking anything that looks like a card number.

Examples
--------
```tcl

qc::debug "Something bad happened."
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"