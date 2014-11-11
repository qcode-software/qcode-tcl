qc::encrypt_bf_tcl
==================

part of [Docs](.)

Usage
-----
`qc::encrypt_bf_tcl key plaintext`

Description
-----------
Encrypt plaintext using TCLLib blowfish package. Return base64 encoded ciphertext.<br/>Ciphertext can be decrypted by qc::decrypt_bf_tcl and qc::decrypt_bf_db.

Examples
--------
```tcl

% encrypt_bf_tcl secretkey "Hello World"
wYYxpOLlcLa7VDcRSERH9g==
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"