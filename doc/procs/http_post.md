qc::http_post
=============

part of [Docs](.)

Usage
-----
` http_post ?-timeout timeout? ?-encoding encoding? ?-content-type content-type? ?-soapaction soapaction? ?-accept accept? ?-authorization authorization? ?-data data? ?-valid_response_codes? ?-headers {name value name value ...}? url ?name value? ?name value? `

Description
-----------
Perform an HTTP POST

Examples
--------
```tcl

% qc::http_post -timeout 30 -content-type &quot;text/plain; charset=utf-8&quot; -accept &quot;text/plain; charset=utf-8&quot; -- http://httpbin.org/post data &quot;Here&#39;s the POST data&quot;
{
    &quot;files&quot;: {},
    &quot;form&quot;: {},
    &quot;url&quot;: &quot;http://httpbin.org/post&quot;,
    &quot;args&quot;: {},
    &quot;headers&quot;: {
        &quot;Content-Length&quot;: &quot;27&quot;,
        &quot;Host&quot;: &quot;httpbin.org&quot;,
        &quot;Content-Type&quot;: &quot;text/plain; charset=utf-8&quot;,
        &quot;Connection&quot;: &quot;keep-alive&quot;,
        &quot;Accept&quot;: &quot;text/plain; charset=utf-8&quot;
    },
&quot;json&quot;: null,
&quot;data&quot;: &quot;data=Here%27s+the+POST+data&quot;
}
% 
% lappend data [list name &quot;firstName&quot; contents &quot;Andres&quot; contenttype &quot;text/plain&quot; contentheader [list &quot;adios: goodbye&quot;]]                                        % lappend data [list name &quot;lastName&quot;  contents &quot;Garcia&quot;]                           % lappend data [list name &quot;file&quot; file &quot;httpPost.tcl&quot; file &quot;basico.tcl&quot; contenttype text/plain filename &quot;c:\\basico.tcl&quot;]                             % lappend data  [list name &quot;AnotherFile&quot; filecontent &quot;httpBufferPost.tcl&quot;]          % lappend data  [list name &quot;submit&quot; contents &quot;send&quot;]

% http_post -headers [list Authorization &quot;OAuth $token&quot;] -data $data -content-type &quot;multipart/form-data&quot; https://httpbin.org/post

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"