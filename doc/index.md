Qcode Tcl Lib Documentation
=============================

* * *

[Database API][1]
-----------------
* Select data out of the db. [`db_1row`](procs/db_1row.md), [`db0or1row`](procs/db_0or1row.md), [`db_foreach`](procs/db_foreach.md)
* DML statements - `INSERT`, `UPDATE`, `DELETE`
* Database Transactions
* Sequences
* Bind variables, quoting and SQL injection
* SQL helpers
* Database Introspection

[Data Types: is, cast, castable][2]
-----------------------------------
* [Is API](is.md)
* [Cast API](cast.md)
* [Castable API](castable.md)

[Authentication][3]
-------------------

[Cookie Handling][4]
--------------------

[Argument Passing in Tcl][5]
----------------------------

[Validating User Input][6]
-------------------------

[Date Handling][7]
----------------------

[Sending Email][8]
------------------
* CC and BCC
* Custom SMTP headers
* Sending plain text and rich HTML
* Automatic plain text alternative to HTML
* Adding attachments via file or base64 string
* Reference attached images in HTML.
* Word wrapping
* UTF-8 Subject

[Error Handling][9]
-------------------
* Return validation errors to the user
* Automatic email notification

* [Form Variables][10]

[Global JSON Response][11]
--------------------------
* [API](response_api.md)

[Handler and Path Registration][12]
----------------------------------
* [Handlers API](handlers-api.md)

[Filters][13]
-------------

[Connection Handlers][14]
-------------------------

[Safe HTML & Markdown][15]
--------------------------

[Security][16]
--------------

* * *

[1]: db.md
[2]: data-types.md
[3]: auth.md
[4]: cookie.md
[5]: args.md
[6]: validation.md
[7]: date.md
[8]: email.md
[9]: error.md
[10]: form-vars.md
[11]: global-json-response.md
[12]: registration.md
[13]: filters.md
[14]: connection-handlers.md
[15]: safe-html-markdown.md
[16]: security.md