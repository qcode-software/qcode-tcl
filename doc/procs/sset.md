qc::sset
========

part of [Docs](.)

Usage
-----
`
        qc::sset varName value
    `

Description
-----------
Set varName to value after having performed a <code>subst</code>.

Examples
--------
```tcl

% set album &quot;Brighten The Corners&quot;
Brighten The Corners
% set band &quot;Pavement&quot;
Pavement
% qc::sset xml {
    &lt;discography-entry&gt;
        [qc::xml band $band]
        [qc::xml album $album]
    &lt;/discography-entry&gt;
}
    
&lt;discography-entry&gt;
&lt;band&gt;Pavement&lt;/band&gt;
&lt;album&gt;Brighten The Corners&lt;/album&gt;
&lt;/discography-entry&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"