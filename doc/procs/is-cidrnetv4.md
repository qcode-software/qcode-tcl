qc::is cidrnetv4
================

part of [Docs](../index.md)

Usage
-----
`qc::is cidrnetv4 string`

Description
----------
Checks if the given string follows the CIDR NETv4 format.

Examples
--------
```tcl

% qc::is cidrnetv4 192.168.1.1
0
% qc::is cidrnetv4 192.168.1.0/24
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
