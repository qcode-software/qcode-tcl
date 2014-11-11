qc::html_a_replace
==================

part of [Docs](.)

Usage
-----
`qc::html_a_replace link url args`

Description
-----------


Examples
--------
```tcl

% html_a_replace Google http://www.google.co.uk 
<a href="http://www.google.co.uk" onclick="location.replace(this.href);return false;">Google</a>
%
% html_a_replace Google http://www.google.co.uk title "Google Search" class highlight
    <a title="Google Search" class="highlight" href="http://www.google.co.uk" onclick="location.replace(this.href);return false;">Google</a>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"