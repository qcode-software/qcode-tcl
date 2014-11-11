qc::encrypt_bf_db
=================

part of [Docs](.)

Usage
-----
`qc::encrypt_bf_db key plaintext`

Description
-----------
Encrypt plaintext using Postgresql's pg_crypto blowfish functions. Return base64 encoded ciphertext.<br/>Ciphertext can be decrypted by qc::decrypt_bf_db and qc::decrypt_bf_tcl.

Examples
--------
```tcl

% encrypt_bf_db secretkey &quot;Hello World&quot;
wYYxpOLlcLa7VDcRSERH9g==
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"