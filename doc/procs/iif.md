qc::iif
=======

part of [Docs](../index.md)

Usage
-----
`
        qc::iif expr true_value false_value
    `

Description
-----------
Inline if statement which returns the appropriate value depending on the boolean expr

Examples
--------
```tcl

% proc xmas_sleeps { date } {
set days [qc::date_days $date "2012-12-25"]
return "There [qc::iif {$days==1} "is $days sleep" "are $days sleeps"] before xmas"
}
% xmas_sleeps 2012-08-21
There are 126 sleeps before xmas
% xmas_sleeps 2012-12-24
There is 1 sleep before xmas
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"