qc::cast_epoch
==============

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast_epoch string`

Description
-----------
Try to convert the given string into an epoch

Examples
--------
```tcl

% cast_epoch 12/5/07
1178924400
# At present dates in this format are assumed to be European DD/MM/YY
%
% cast_epoch yesterday
1192569505
%
% cast_epoch 2007-10-16
1192489200
% 
# times can be hh:mm or hh:mm:ss
% cast_epoch "2007-10-16 10:12:36"
1192525956
    # With ISO offset timezone in formats -hh, -hhmm or -hh:mm
    % cast_epoch "2007-10-16 12:14:34.15445 +05"
    1192518874

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"