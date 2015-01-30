Security
========
part of [Qcode Documentation](index.md)

* * *

Passwords
---------

The qcode-tcl library provides a proc for hashing passwords: [`qc::password_hash`].

The PostgreSQL module [pgcrypto] should be installed as [`qc::password_hash`] makes use of the `crypt` function. The procedure uses the blowfish `bf` algorithm and a default iteration count of 7 however the iteration count may be changed when using [`qc::password_hash`].

More details about the crypt function as well as how to verify passwords can be found in the [Password Hashing Functions] section of pgcrypto documentation.

### Complexity Checking

It's valuable to check if a password meets a certain level of complexity to enhance the security of the password. [`qc::password_complexity_check`] is provided for this purpose.


SQL Injection
-------------

The qcode-tcl library provides a number of helper procedures to construct and execute SQL statements. Using these helper procedures will substantially reduce chances of suffering from an SQL injection attack. The [Database API] documentation explains how to interact with a database and how to use the helper procedures. The section on [Bind Variables] details how user input for queries is handled.

For further details on SQL Injection and prevention see the OWASP documentation for [SQLInjection] and [SQL Injection Prevention].


Cross Site Scripting (XSS)
--------------------------

There are procedures provided in the library that should be used to check and sanitize user input in order to prevent cross site scripting attacks.

Procedures supplied:

* [`qc::html_escape`]
* [`qc::strip_html`]
* [`qc::is safe_html`]
* [`qc::is safe_markdown`]
* [`qc::html_sanitize`]

See [Safe HTML & Markdown] for more details on dealing with safe HTML and safe markdown in the qcode-tcl library.

For further details on Cross Site Scripting and prevention see the OWASP documentation for [XSS] and [XSS Prevention].


Cross Site Request Forgery (CSRF)
---------------------------------

For each user session created a token is generated referred to as the `authenticity token` and each authenticity token is unique to each session. This token should be used in all forms as a hidden input. Whenever a form is submitted that will alter data in some way the authenticity token should be present and checked against the token stored for that users current session.

To obtain the authenticity token for the users current session use [`qc::session_authenticity_token`]. For adding the hidden input on a form [`qc::form_authenticity_token`] can be used to generate the hidden input element with the authenticity token. If using the form template procedure [`qc::form`] the authenticity token will automatically be added to the form for any method that is not `GET`.


For further details on Cross Site Scripting and prevention see the OWASP documentation for [CSRF] and [CSRF Prevention].

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[`qc::password_hash`]: procs/password_hash.md
[`qc::password_complexity_check`]: procs/password_complexity_check.md
[pgcrypto]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html
[Password Hashing Functions]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html#AEN157245

[Database API]: db.md
[Bind Variables]: db.md#bind-variables

[SQL Injection]: https://www.owasp.org/index.php/SQL_Injection
[SQL Injection Prevention]: https://www.owasp.org/index.php/SQL_Injection_Prevention_Cheat_Sheet

[XSS]: https://www.owasp.org/index.php/Cross_Site_Scripting
[XSS Prevention]: https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet

[`qc::html_escape`]: procs/html_escape.md
[`qc::strip_html`]: procs/strip_html.md
[`qc::is safe_html`]: procs/is-safe_html.md
[`qc::is safe_markdown`]: procs/is-safe_markdown.md
[`qc::html_sanitize`]: procs/html_sanitize.md
[Safe HTML & Markdown]: safe-html-markdown.md

[CSRF]: https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)
[CSRF Prevention]: https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29_Prevention_Cheat_Sheet

[`qc::session_authenticity_token`]: procs/session_authenticity_token.md
[`qc::form_authenticity_token`]: procs/form_authenticity_token.md
[`qc::form`]: procs/form.md