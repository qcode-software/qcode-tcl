qc::binary_convert_unit_prefix2mult
===================================

part of [Docs](.)

Usage
-----
`qc::binary_convert_unit_prefix2mult prefix`

Description
-----------
Return multiplier for a binary unit prefix.

Examples
--------
```tcl

% qc::binary_convert_unit_prefix2mult K
1024.0
% qc::binary_convert_unit_prefix2mult kilo
1024.0
% qc::binary_convert_unit_prefix2mult Kilo
1024.0
% qc::binary_convert_unit_prefix2mult Ki
1024.0
% qc::binary_convert_unit_prefix2mult kibi
1024.0
% qc::binary_convert_unit_prefix2mult Kibi
1024.0
    % qc::binary_convert_unit_prefix2mult M
1048576.0
% qc::binary_convert_unit_prefix2mult G
1073741824.0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"