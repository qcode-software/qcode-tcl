qc::http_get
============

part of [Docs](.)

Usage
-----
` http_get  ?-timeout timeout? ?-headers {name value name value ...}? url `

Description
-----------


Examples
--------
```tcl

> qc::http_get http://httpbin.org/get?ourformvar=999&anotherformvar=123
{
"url": "http://httpbin.org/get?ourformvar=999&anotherformvar=123",
"headers": {
    "Content-Length": "",
    "Host": "httpbin.org",
    "Content-Type": "",
    "Connection": "keep-alive",
    "Accept": "*/*"
},
"args": {
    "anotherformvar": "123",
    "ourformvar": "999"
},
}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"