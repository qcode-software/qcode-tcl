qc::password_complexity_check
=============================

part of [Docs](../index.md)

Usage
-----
`qc::password_complexity_check password ?min int? ?max int? ?minclasses int?`

Description
-----------
Checks password against min, max and minclasses complexity requirements.

Max size is limited to 72.

Minclasses specifies the minimum number of classes of characters that must be present. Character classes are uppercase, lowercase, numbers, and punctuation. Minclasses is limited from 1 to 4.

Min, max, and minclasses have default values if any aren't specified:

arg | default value
----|--------------
| min | 7
| max | 72
| minclasses | 1

Examples
--------

```tcl

% qc::password_complexity_check "foo"
Your password must be at least 7 characters long

% qc::password_complexity_check "foo" min 3
true

% qc::pasword_complexity_check "foo" min 3 minclasses 2
Your password must contain at least 2 of uppercase, lowercase, numeric or punctuation

% qc::password_complexity_check "Foo100!" minclasses 4
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"