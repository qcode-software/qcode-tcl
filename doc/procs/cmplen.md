qc::cmplen
==========

part of [Docs](.)

Usage
-----
`
        qc::cmplen string1 string2
    `

Description
-----------
Compare length of 2 strings

Examples
--------
```tcl

% qc::cmplen &quot;ox&quot; &quot;hippopotamus&quot;
-1
% qc::cmplen &quot;hippopotamus&quot; &quot;ox&quot;
1
% qc::cmplen &quot;ox&quot; &quot;ox&quot;
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"