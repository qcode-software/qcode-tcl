qc::format_cc_masked_string
===========================

part of [Docs](.)

Usage
-----
`qc::format_cc_masked_string string ?prefix? ?suffix?`

Description
-----------


Examples
--------
```tcl

% format_cc_masked_string 4111111111111111 6 4
4111 11** **** 1111
% format_cc_masked_string "Any old 4111 1111 1111 1111 or other 5555555555554444" 4 4
Any old 4111 **** **** 1111 or other 5555 **** **** 4444

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"