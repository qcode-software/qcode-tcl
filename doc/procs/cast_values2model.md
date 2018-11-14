qc::cast_values2model
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast_values2model args`

Description
-----------
Check the data types of the values against the definitions for these names.

Returns a new list of values after casting to appropriate type.

Throws an error if type-checking fails.

Examples
--------
```tcl

% qc::cast_values2model post_title "Hello World"
post_title {Hello World}

% qc::cast_values2model post_title {<h1>Title</h1>}
<ul>
    <li>&quot;&lt;h1&gt;Title&lt;/h1&gt;...&quot; failed to meet the constraint plain_string_check.</li>
</ul>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"