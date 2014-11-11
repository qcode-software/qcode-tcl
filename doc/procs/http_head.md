qc::http_head
=============

part of [Docs](.)

Usage
-----
`qc::http_head args`

Description
-----------
Return a dict of name value pairs returned by the server in the HTTP header

Examples
--------
```tcl

% qc::http_head www.google.co.uk
% Expires -1 http {HTTP/1.1 200 OK} Transfer-Encoding chunked X-Frame-Options SAMEORIGIN Content-Type {text/html; charset=ISO-8859-1} Cache-Control {private, max-age=0} Date {Thu, 23 Aug 2012 14:42:23 GMT} X-XSS-Protection {1; mode=block} Server gws P3P {CP=&quot;This is not a P3P policy! See http://www.google.com/support/accounts/bin/answer.py?hl=en&amp;answer=151657 for more info.&quot;} Set-Cookie {{PREF=ID=a756df18ac806a1b:FF=0:TM=1345732943:LM=1345732943:S=pks7ngzKuTVPwX92; expires=Sat, 23-Aug-2014 14:42:23 GMT; path=/; domain=.google.co.uk} {NID=63=RM68tXvZZYQ6EMUebcB7iyXIbKwXH1PoXgkNyomu_tF5-DBQ1vhBw_o8A_n0N-zhdNbTp7_eOZ8A90i3VsxT19TvuW9ld-kiidOfY-Tn8jaDVXs3C7i6em6ITp3MFLbn; expires=Fri, 22-Feb-2013 14:42:23 GMT; path=/; domain=.google.co.uk; HttpOnly}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"