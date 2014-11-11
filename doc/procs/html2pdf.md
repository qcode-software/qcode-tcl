qc::html2pdf
============

part of [Docs](.)

Usage
-----
`qc::html2pdf args`

Description
-----------


Examples
--------
```tcl

% html2pdf -encoding base64 -timeout 10 "<html><p>This is an HTML file to be converted to a PDF</p></html>"
JVBERi0xLjQKMSAwIG9iago8PAovVGl0bGUgKP7/KQovUHJvZHVjZXIgKHdraHRtbHRvcGRmKQov
Q3JlYXRpb25EYXRlIChEOjIwMTAwODIwMTIzMjI1KQo+PgplbmRvYmoKNCAwIG9iago8PAovVHlw
ZSAvRXh0R1N0YXRlCi9TQSB0cnVlCi9TTSAwLjAyCi9jYSAxLjAKL0NBIDEuMAovQUlTIGZhbHNl
Ci9TTWFzayAvTm9uZT4+CmVuZG9iago1IDAgb2JqClsvUGF0dGVybiAvRGV2aWNlUkdCXQplbmRv
YmoKOCAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovUGFnZXMgMiAwIFIKPj4KZW5kb2JqCjYgMCBv
...
% html2pdf -encoding binary -timeout 10 "<html><p>This is an HTML file to be converted to a PDF</p></html>"
1 0 obj
<<
/Title (þÿ)
...
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"