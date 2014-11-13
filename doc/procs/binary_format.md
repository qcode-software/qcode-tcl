qc::binary_format
=================

part of [Docs](../index.md)

Usage
-----
`qc::binary_format args`

Description
-----------
Return formatted string to display a binary file size in the most appropriate units.<br/>Usage: qc::binary_format ?-sigfigs sigfigs? size<br/>qc::binary_format ?-sigfigs sigfigs? size units

Examples
--------
```tcl

% qc::binary_format 44444 MB 
43.4 GB
% qc::binary_format 44444 MBytes
43.4 GB
% qc::binary_format 44444 megabytes 
43.4 GB
    % qc::binary_format 44444 megabyte
43.4 GB
% qc::binary_format "44444Mb"
43.4 Gb
    % qc::binary_format "44444Mbit"
43.4 Gb
    % qc::binary_format "44444 megabit"
43.4 Gb
    % qc::binary_format "44444 megabit"
43.4 Gb
% qc::binary_format -sigfigs 5 44444 Mb
43.402 Gb

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"