qc::sset
========

part of [Docs](../index.md)

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

% set album "Brighten The Corners"
Brighten The Corners
% set band "Pavement"
Pavement
% qc::sset xml {
    <discography-entry>
        [qc::xml band $band]
        [qc::xml album $album]
    </discography-entry>
}
    
<discography-entry>
<band>Pavement</band>
<album>Brighten The Corners</album>
</discography-entry>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"