qc::my
======

part of [Docs](../index.md)

Usage
-----
`
        qc::my query
    `

Description
-----------
Multifunction proc to return information about the local OS.
        Written to be debian specific but may work on some other Linux distributions.

Examples
--------
```tcl

% qc::my hostname
thishost

# Fully qualified domain name
% qc::my fqdn
thishost.ourdomain.co.uk

% qc::my domain
ourdomain.co.uk

% qc::my ip 
192.168.1.66

% qc::my username
angus

# Which architecture?
% qc::my arch
amd64

% qc::my total_memory
10217812

# Amazon EC2 instances only:
# Return my instance id.
% qc::my instance_id
i-13f1333f
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"