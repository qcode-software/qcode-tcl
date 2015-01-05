qc::db_validation_message
===========

part of [Database API](../db.md)

Usage
-----
`db_validation_message table column`

Dependency
----
A table named "validation_messages" with three columns (table_name, column_name, message) should exist in the database and be used to update or add any validation messages.

Description
-----------
Returns the validation message associated with the given table and column from the validation_messages table.

If the table name does not exist then only the column name will be used to find a validation message.

Examples
--------
```tcl

% db_validation_message user email
Please enter a valid email address.

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"