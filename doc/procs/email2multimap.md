qc::email2multimap
==================

part of [Docs](.)

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
Message-ID: &lt;CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com&gt;
Subject: Memo
From: Bernhard van Woerden &lt;bernhard@qcode.co.uk&gt;
To: Bernhard van Woerden &lt;bernhard@qcode.co.uk&gt;
Content-Type: multipart/mixed; boundary=0016e6d9a38e403c6904c774c888

--0016e6d9a38e403c6904c774c888
Content-Type: multipart/alternative; boundary=0016e6d9a38e403c6004c774c886

--0016e6d9a38e403c6004c774c886
Content-Type: text/plain; charset=ISO-8859-1

Please see the attached.

- Bernhard

--0016e6d9a38e403c6004c774c886
Content-Type: text/html; charset=ISO-8859-1

Please see the attached.&lt;div&gt;&lt;br&gt;&lt;/div&gt;&lt;div&gt;- Bernhard&lt;/div&gt;

--0016e6d9a38e403c6004c774c886--
--0016e6d9a38e403c6904c774c888
Content-Type: text/plain; charset=US-ASCII; name=&quot;Memo.txt&quot;
Content-Disposition: attachment; filename=&quot;Memo.txt&quot;
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h5z7vyc30

V291bGQgdGhlIGxhc3QgcGVyc29uIHRvIGxlYXZlIHBsZWFzZSB0dXJuIHRoZSBsaWdodHMgb2Zm
Lg==
--0016e6d9a38e403c6904c774c888--
}
    % qc::email2multimap $email
MIME-Version 1.0 Received {by 10.216.2.9 with HTTP; Fri, 17 Aug 2012 04:51:36 -0700 (PDT)} Date {Fri, 17 Aug 2012 12:51:36 +0100} Delivered-To bernhard@qcode.co.uk Message-ID &lt;CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com&gt; Subject Memo From {Bernhard van Woerden &lt;bernhard@qcode.co.uk&gt;} To {Bernhard van Woerden &lt;bernhard@qcode.co.uk&gt;} Content-Type {multipart/mixed; boundary=0016e6d9a38e403c6904c774c888} bodies {{Content-Type {multipart/alternative; boundary=0016e6d9a38e403c6004c774c886} bodies {{Content-Type {text/plain; charset=ISO-8859-1} body {Please see the attached.

- Bernhard}} {Content-Type {text/html; charset=ISO-8859-1} body {Please see the attached.&lt;div&gt;&lt;br&gt;&lt;/div&gt;&lt;div&gt;- Bernhard&lt;/div&gt;}}}} {Content-Type {text/plain; charset=US-ASCII; name=&quot;Memo.txt&quot;} Content-Disposition {attachment; filename=&quot;Memo.txt&quot;} Content-Transfer-Encoding base64 X-Attachment-Id f_h5z7vyc30 body {Would the last person to leave please turn the lights off.}}}    
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"