qc::db_init
===========

part of [Database API](../db.md)

Usage
-----
`db_init`

Dependency
----
A PostgreSQL database is up and running and the current database user is a superuser.

Description
-----------
Initialises the database by creating tables, domains, enums, sequences, extensions, functions, and the anonymous user if they do not exist.

The objects created are required by the qcode-tcl library. For more information see [Data Model Dependencies].

### Tables
* param
* users
* file
* image
* validation_messages
* session
* schema
  * Initialisted with value `1`
* perm_category
* perm_class
* perm
* user_perm
* stick
* file_alias_path
* form
* optional
* required

### Domains
* plain_text
* plain_string
* url
* url_path

### Enums
* user_state
* perm_method

### Sequences
* user_id_seq
* file_id_seq
* perm_category_id_seq
* perm_class_id_seq
* perm_id_seq

### Extensions
* pgcrypto

### Functions
* sha1 (for pgcrypto extension)

### Users
* Anonymous

Examples
--------
```tcl

% db_init

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Data Model Dependencies]: ../data-model-dependencies.md