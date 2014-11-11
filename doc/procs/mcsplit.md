qc::mcsplit
===========

part of [Docs](../index.md)

Usage
-----
`
        qc::mcsplit sting splitString
    `

Description
-----------
Split the string on the supplied string which can be of arbitrary length (unlike split).

Examples
--------
```tcl

% set test "this||is||a||delimited||string"
this||is||a||delimited||string
% split $test {||}
this {} is {} a {} delimited {} string
% qc::mcsplit $test {||}
this is a delimited string
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"