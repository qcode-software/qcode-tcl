qc::http_post
=============

part of [Docs](../index.md)

Usage
-----
` http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-accept accept? ?-authorization authorization? ?-data data? ?-valid_response_codes? ?-headers {name value name value ...}? url ?name value? ?name value? `

Description
-----------
Perform an HTTP POST

Examples
--------
```tcl

% qc::http_post -timeout 30 -content-type "text/plain; charset=utf-8" -accept "text/plain; charset=utf-8" -- http://httpbin.org/post data "Here's the POST data"
{
    "files": {},
    "form": {},
    "url": "http://httpbin.org/post",
    "args": {},
    "headers": {
        "Content-Length": "27",
        "Host": "httpbin.org",
        "Content-Type": "text/plain; charset=utf-8",
        "Connection": "keep-alive",
        "Accept": "text/plain; charset=utf-8"
    },
"json": null,
"data": "data=Here%27s+the+POST+data"
}
% 
% lappend data [list name "firstName" contents "Andres" contenttype "text/plain" contentheader [list "adios: goodbye"]]                                        % lappend data [list name "lastName"  contents "Garcia"]                           % lappend data [list name "file" file "httpPost.tcl" file "basico.tcl" contenttype text/plain filename "c:\\basico.tcl"]                             % lappend data  [list name "AnotherFile" filecontent "httpBufferPost.tcl"]          % lappend data  [list name "submit" contents "send"]

% http_post -headers [list Authorization "OAuth $token"] -data $data -content-type "multipart/form-data" https://httpbin.org/post

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"