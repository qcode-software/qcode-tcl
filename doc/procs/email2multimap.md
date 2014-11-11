qc::email2multimap
==================

part of [Docs](../index.md)

Usage
-----
`qc::email2multimap text`

Description
-----------


Examples
--------
```tcl

    % set email {
MIME-Version: 1.0
Received: by 10.216.2.9 with HTTP; Fri, 17 Aug 2012 04:51:36 -0700 (PDT)
Date: Fri, 17 Aug 2012 12:51:36 +0100
Delivered-To: bernhard@qcode.co.uk
Message-ID: <CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com>
Subject: Memo
From: Bernhard van Woerden <bernhard@qcode.co.uk>
To: Bernhard van Woerden <bernhard@qcode.co.uk>
Content-Type: multipart/mixed; boundary=0016e6d9a38e403c6904c774c888

--0016e6d9a38e403c6904c774c888
Content-Type: multipart/alternative; boundary=0016e6d9a38e403c6004c774c886

--0016e6d9a38e403c6004c774c886
Content-Type: text/plain; charset=ISO-8859-1

Please see the attached.

- Bernhard

--0016e6d9a38e403c6004c774c886
Content-Type: text/html; charset=ISO-8859-1

Please see the attached.<div><br></div><div>- Bernhard</div>

--0016e6d9a38e403c6004c774c886--
--0016e6d9a38e403c6904c774c888
Content-Type: text/plain; charset=US-ASCII; name="Memo.txt"
Content-Disposition: attachment; filename="Memo.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h5z7vyc30

V291bGQgdGhlIGxhc3QgcGVyc29uIHRvIGxlYXZlIHBsZWFzZSB0dXJuIHRoZSBsaWdodHMgb2Zm
Lg==
--0016e6d9a38e403c6904c774c888--
}
    % qc::email2multimap $email
MIME-Version 1.0 Received {by 10.216.2.9 with HTTP; Fri, 17 Aug 2012 04:51:36 -0700 (PDT)} Date {Fri, 17 Aug 2012 12:51:36 +0100} Delivered-To bernhard@qcode.co.uk Message-ID <CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com> Subject Memo From {Bernhard van Woerden <bernhard@qcode.co.uk>} To {Bernhard van Woerden <bernhard@qcode.co.uk>} Content-Type {multipart/mixed; boundary=0016e6d9a38e403c6904c774c888} bodies {{Content-Type {multipart/alternative; boundary=0016e6d9a38e403c6004c774c886} bodies {{Content-Type {text/plain; charset=ISO-8859-1} body {Please see the attached.

- Bernhard}} {Content-Type {text/html; charset=ISO-8859-1} body {Please see the attached.<div><br></div><div>- Bernhard</div>}}}} {Content-Type {text/plain; charset=US-ASCII; name="Memo.txt"} Content-Disposition {attachment; filename="Memo.txt"} Content-Transfer-Encoding base64 X-Attachment-Id f_h5z7vyc30 body {Would the last person to leave please turn the lights off.}}}    
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"