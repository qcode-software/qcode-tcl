qc::exec_proxy
==============

part of [Docs](../index.md)

Usage
-----
`
        qc::exec_proxy ?-timeout ms? command ?arg? ?arg? ...
    `

Description
-----------
Execute the supplied command.
        If running on aolserver will use ns_proxy, otherwise the command is executed directly.
        A timeout can be optionally supplied in milliseconds. 
        Note, timeout is ignored if not running via ns_proxy.

Examples
--------
```tcl

% qc::exec_proxy hostname
myhostname
1> qc::exec_proxy -timeout 1000 wget http://cdimage.debian.org/debian-cd/6.0.5/amd64/iso-cd/debian-6.0.5-amd64-CD-1.iso
wait for proxy "exec-proxy-0" failed: timeout waiting for evaluation
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"