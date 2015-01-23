Filters
=======
part of [Qcode Documentation](index.md)

* * *

Filters, registered on Naviserver with `ns_register_filter`, allow for certain tasks to be carried out at certain stages of Naviserver authorization. See the [Naviserver register docs] for more information.

The qcode-tcl library provides a few useful filters.


qc::filter_validate
---------------

The task of this filter is to validate input from the client before the request is handled by a request handler.

When a request comes in and this filter is called it will check if the request has been [registered for validation] and if a [request handler] exists to handle the request.

If both of these conditions are met then the relevant data for the request is validated against the data model. If a [custom validation handler] exists for the request then that is called.

If anything failed validation then the [JSON response] is returned to the client otherwise the server continues normal execution.

### Usage

This filter is intended to be used prior to the request being handled so that invalid data isn't passed through to the request handler. This means that `qc::filter_validate` should be registered with Naviserver during `preauth` or `postauth` but never for `trace`.

### Examples

Pre-authorization.

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter preauth $http_method /* qc::filter_validate
}
```
Post-authorization.

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter postauth $http_method /* qc::filter_validate
}
```


qc::filter_authenticate
-------------------

The task of this filter is to check if the session and authentication tokens are present and valid and act accordingly.

When this filter is called it will check if the request has been [registered for authentication]. If so then a check is done to determine if the session is valid.

If the session is valid then the request method is checked. If it's not a GET or HEAD request the authenticity token must be checked for validity. If the token is invalid then an error is returned to the client. Otherwise  the server continues normal execution.

If the session is invalid or not present then the user is logged in as the [anonymous user] and given the anonymous session ID.

This filter also updates the anonymous session if it is more than an hour old.

See [Authentication] for more information on sessions and the authentication process.

### Usage

This filter is intended to be used prior to the request being handled so that only authenticated users have their requests handled. This means that `qc::filter_authenticate` should be registered with Naviserver during `preauth` or `postauth` but never for `trace`.

### Examples

Pre-authorization.

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter preauth $http_method /* qc::filter_authenticate
}
```
Post-authorization.

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter postauth $http_method /* qc::filter_authenticate
}
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[Naviserver register docs]: http://naviserver.sourceforge.net/n/naviserver/files/ns_register.html#3
[JSON response]: global-json-response.md
[registered for validation]: registration.md
[request handler]: registration.md
[custom validation handler]: registration.md
[registered for authentication]: registration.md
[anonymous user]: auth.md
[Authentication]: auth.md