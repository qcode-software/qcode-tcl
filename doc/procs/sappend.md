qc::sappend
===========

part of [Docs](.)

Usage
-----
`
        qc::sappend varName value
    `

Description
-----------
Append value to the contents of varName having first performed a <code>subst</code>.

Examples
--------
```tcl

% set album &quot;Welcome to Mali&quot;
Welcome to Mali
% set band &quot;Amadou &amp; Mariam&quot;
Amadou &amp; Mariam
% qc::sappend xml {
    &lt;discography-item&gt;
        [qc::xml band $band]
        [qc::xml album $album]
    &lt;/discography-item&gt;
}
    
&lt;discography-item&gt;
&lt;band&gt;Pavement&lt;/band&gt;
&lt;album&gt;Brighten The Corners&lt;/album&gt;
&lt;/discography-item&gt;
&lt;discography-item&gt;
&lt;band&gt;Amadou &amp;amp; Mariam&lt;/band&gt;
&lt;album&gt;Welcome to Mali&lt;/album&gt;
&lt;/discography-item&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"