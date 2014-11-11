qc::iif
=======

part of [Docs](.)

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
set days [qc::date_days $date &quot;2012-12-25&quot;]
return &quot;There [qc::iif {$days==1} &quot;is $days sleep&quot; &quot;are $days sleeps&quot;] before xmas&quot;
}
% xmas_sleeps 2012-08-21
There are 126 sleeps before xmas
% xmas_sleeps 2012-12-24
There is 1 sleep before xmas
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"