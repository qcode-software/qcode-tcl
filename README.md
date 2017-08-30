<p align="center">
<img src="logo_qcode_420x120.png" alt="Qcode" title="Qcode" />
</p>

Qcode Tcl Lib
=============

A library for building Tcl Web Apps running on Naviserver.

* * *

## 1. Tutorials

* [An Introduction to Qcode Tcl][20]
* [Setting Up a Connection Marshal and Request Handlers][18]
* [How to Define a New Data Type (Domain)][19]

## 2. [Handler and Path Registration][12]
* [Handlers API](doc/handlers-api.md)

## 3. [Connection Handlers][14]

## 4. [Connection Response][11]
* [API](doc/response_api.md)

## 5. [Filters][13]

## 6. [Authentication][3]

## 7. [Argument Passing in Tcl][5]

## 8. [Validating User Input][6]

## 9. [Cookie Handling][4]

## 10. [Date Handling][7]

## 11. [Database API][1]

* Select data out of the db. [`db_1row`](doc/procs/db_1row.md), [`db0or1row`](doc/procs/db_0or1row.md), [`db_foreach`](doc/procs/db_foreach.md)
* DML statements - `INSERT`, `UPDATE`, `DELETE`
* Database Transactions
* Sequences
* Bind variables, quoting and SQL injection
* SQL helpers
* Database Introspection

## 12. [Data Types][2]

* [`qc::is` Ensemble](doc/is.md)
* [`qc::cast` Ensemble](doc/cast.md)
* [`qc::castable` Ensemble](doc/castable.md)
* [Define a new data type](doc/data-type-define.md)

## 13. [Sending Email][8]
* CC and BCC
* Custom SMTP headers
* Sending plain text and rich HTML
* Automatic plain text alternative to HTML
* Adding attachments via file or base64 string
* Reference attached images in HTML.
* Word wrapping
* UTF-8 Subject

## 14. [Error Handling][9]
* Return validation errors to the user
* Automatic email notification
* [Form Variables][10]

## 15. [Safe HTML & Markdown][15]

## 16. [Security][16]
* Passwords
* SQL Injection
* Cross Site Scripting
* Cross Site Request Forgery

## 17. Appendix: Naviserver
* [Naviserver Introduction](doc/naviserver-introduction.md)
* [Naviserver Example Configs](doc/naviserver-config-examples.md)
* [Postgresql Setup](doc/postgresql-setup.md)

## 18. [Appendix: Data Model Dependencies][17]

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"





[1]: doc/db.md
[2]: doc/data-types.md
[3]: doc/auth.md
[4]: doc/cookie.md
[5]: doc/args.md
[6]: doc/validation.md
[7]: doc/date.md
[8]: doc/email.md
[9]: doc/error.md
[10]: doc/form-vars.md
[11]: doc/connection-response.md
[12]: doc/registration.md
[13]: doc/filters.md
[14]: doc/connection-handlers.md
[15]: doc/safe-html-markdown.md
[16]: doc/security.md
[17]: doc/data-model-dependencies.md
[18]: doc/setting-up.md
[19]: doc/data-type-define.md
[20]: doc/installation.md
