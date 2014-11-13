qc::log
=======

part of [Docs](../index.md)

Usage
-----
`
        qc::log ?severity? message
    `

Description
-----------
If running in naviserver then write message to nsd log using App: prefix. 
        Otherwise write message to stout or stderr.
        Default severity argument to "Notice". 
        Filter message by masking anything that looks like a card number.
        Usage: qc::log ?Severity? message

Examples
--------
```tcl

% qc::log Debug "Debug this"
% qc::log Notice "Notice this"
% qc::log "Notice this"
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"