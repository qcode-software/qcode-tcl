qc::password_hash
=================

part of [Docs](../index.md)

Usage
-----
`qc::password_hash password ?strength?`

Description
-----------
Returns a salted password hash using blowfish with an iteration count of $strength.

If `strength` isn't specified a default value of `7` is used.

Examples
--------

```tcl

% qc::password_hash "foo"
$2a$07$w66Tey5cyBcjcn5CxgHoxeGSgzN1Gpe.LEDe/.gs4MUocnErnzTkG

% qc::password_hash "foo" 10
$2a$10$UK0tBk7rhaHzsH8XeFqP7eb9snUN8vVlWPmpQT5/IA5JVphh4wzbi

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"