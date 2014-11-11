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

&gt; qc::http_get http://httpbin.org/get?ourformvar=999&amp;anotherformvar=123
{
&quot;url&quot;: &quot;http://httpbin.org/get?ourformvar=999&amp;anotherformvar=123&quot;,
&quot;headers&quot;: {
    &quot;Content-Length&quot;: &quot;&quot;,
    &quot;Host&quot;: &quot;httpbin.org&quot;,
    &quot;Content-Type&quot;: &quot;&quot;,
    &quot;Connection&quot;: &quot;keep-alive&quot;,
    &quot;Accept&quot;: &quot;*/*&quot;
},
&quot;args&quot;: {
    &quot;anotherformvar&quot;: &quot;123&quot;,
    &quot;ourformvar&quot;: &quot;999&quot;
},
}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"