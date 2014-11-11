qc::email_header_fold
=====================

part of [Docs](.)

Usage
-----
`qc::email_header_fold string`

Description
-----------
Fold header into lines starting with a space as per rfc2822

Examples
--------
```tcl

    % qc::email_header_fold &quot;This is a long line over the 78 characters allowed before folding at a word boundary where possible&quot;
This is a long line over the 78 characters allowed before folding at a word
 boundary where possible
    % qc::email_header_fold &quot;Non ASCII is treated like this pound sign £&quot;
Non ASCII is treated like this pound sign =?UTF-8?Q?=C2=A3?=
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"