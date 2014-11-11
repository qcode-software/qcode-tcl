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

% set album "Welcome to Mali"
Welcome to Mali
% set band "Amadou & Mariam"
Amadou & Mariam
% qc::sappend xml {
    <discography-item>
        [qc::xml band $band]
        [qc::xml album $album]
    </discography-item>
}
    
<discography-item>
<band>Pavement</band>
<album>Brighten The Corners</album>
</discography-item>
<discography-item>
<band>Amadou &amp; Mariam</band>
<album>Welcome to Mali</album>
</discography-item>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"