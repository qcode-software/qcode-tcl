<p align="center">
<img src="../logo_qcode_420x120.png" alt="Qcode" title="Qcode" />
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
* [Handlers API](handlers-api.md)

## 3. [Connection Handlers][14]

## 4. [Connection Response][11]
* [API](response_api.md)

## 5. [Filters][13]

## 6. [Authentication][3]

## 7. [Argument Passing in Tcl][5]

## 8. [Validating User Input][6]

## 9. [Cookie Handling][4]

## 10. [Date Handling][7]

## 11. [Database API][1]

* Select data out of the db. [`db_1row`](procs/db_1row.md), [`db0or1row`](procs/db_0or1row.md), [`db_foreach`](procs/db_foreach.md)
* DML statements - `INSERT`, `UPDATE`, `DELETE`
* Database Transactions
* Sequences
* Bind variables, quoting and SQL injection
* SQL helpers
* Database Introspection

## 12. [Data Types][2]

* [`qc::is` Ensemble](is.md)
* [`qc::cast` Ensemble](cast.md)
* [`qc::castable` Ensemble](castable.md)
* [Define a new data type](data-type-define.md)

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
* [Naviserver Introduction](naviserver-introduction.md)
* [Naviserver Example Configs](naviserver-config-examples.md)
* [Postgresql Setup](postgresql-setup.md)

## 18. [Appendix: Data Model Dependencies][17]

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"





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
[11]: connection-response.md
[12]: registration.md
[13]: filters.md
[14]: connection-handlers.md
[15]: safe-html-markdown.md
[16]: security.md
[17]: data-model-dependencies.md
[18]: setting-up.md
[19]: data-type-define.md
[20]: installation.md
