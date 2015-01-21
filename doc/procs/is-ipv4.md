qc::is ipv4
===========

part of [Docs](../index.md)

Usage
-----
`qc::is ipv4 string`

Description
-----------
Checks if the given string follows the IPv4 format.

Examples
--------
```tcl

% qc::is ipv4  2001:0db8:85a3:0042:0000:8a2e:0370:7334
0
% qc::is ipv4 192.0.1
0
% qc::is ipv4 192.168.1.1
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"