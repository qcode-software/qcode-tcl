qc::data_type_error_check
===============

part of [Docs](../index.md)

Usage
-----
`qc::data_type_error_check data_type value`

Description
-----------
Checks the given value against the data type and reports any error.

Examples
--------
```tcl

% qc::data_type_error_check varchar(2) foo
"foo..." is too long. Must be 2 characters or less.

% qc::data_type_error_check int4 foo
"foo" is not a valid integer. It must be a number between -2147483648 and 2147483647.

% qc::data_type_error_check safe_html "<script>alert('Foo');</script>"
"<script>alert('Foo');</script>..." contains invalid or unsafe HTML.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"