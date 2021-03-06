Qcode-tcl Data Types
========
part of [Qcode Documentation](index.md)

-----

Qcode-tcl extends the standard postgresql data types with several custom data types. You can also [create your own data types](data-type-define.md).

Definitions for the Qcode-tcl data types initialised in db_init are as follows:

|	Name	       | Description	|
|	------------ | ------------ |
| plain_text   | character string, can not contain html tags (<>) |
| plain_string | character string with maximum length of 255, can not contain html tags (<>) |
| url          | a fully qualified domain name |
| url_path     | a relative HTML path |
| user_state   | enumeration ('ACTIVE', 'DISABLED') |
| perm_method  | enumeration ('READ', 'WRITE', 'APPEND') |

For reference, see [Postgres data types](https://www.postgresql.org/docs/9.5/static/datatype.html#DATATYPE-TABLE).
