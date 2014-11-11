qc::sendmail
============

part of [Sending Email](../qc/wiki/SendingEmail)

Usage
-----
`qc::sendmail mail_from rcpts body args`

Description
-----------
Connect to the smtp host and send email message<br/>mail_from is a bare email address eg. root@localhost<br/>rcpts is a list of bare rcpt email addresses<br/>body is the plain text message usually in mime format.<br/>args is a name value pair list of mail headers

Examples
--------
```tcl

% 
% sendmail $mail_from $rcpt_to $text Subject $subject Date [qc::format_timestamp_http now] MIME-Version 1.0 Content-Transfer-Encoding quoted-printable Content-Type &quot;text/plain; charset=utf-8&quot; From $from To $to

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"