qc::log
=======

part of [Docs](.)

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

% qc::log Debug &quot;Debug this&quot;
% qc::log Notice &quot;Notice this&quot;
% qc::log &quot;Notice this&quot;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"