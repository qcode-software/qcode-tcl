Filters
=======
part of [Qcode Documentation](index.md)

* * *

Filters, registered on Naviserver with `ns_register_filter`, allow for certain tasks to be carried out at certain stages of Naviserver authorization. See the [Naviserver register docs] for more information.

The qcode-tcl library provides a few useful filters.


qc::filter_validate
---------------

The task of this filter is to validate input from the client before the request is handled by a request handler.

When a request comes in and this filter is called it will check if the request has been [registered] and if a [request handler] exists to handle the request.

If both of these conditions are met then the relevant data for the request is validated against the data model. If a [custom validation handler] exists for the request then that is called.

If anything failed validation then the [JSON response] is returned to the client.

### Usage

This filter is intended to be used prior to the request being handled so that invalid data isn't passed through to the request handler. This means that `qc::filter_validate` should be registered with Naviserver during `postauth` but never for `trace`.

### Examples

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter postauth $http_method /* qc::filter_validate
}
```


qc::filter_authenticate
-------------------

The task of this filter is to check if the session and authentication tokens are present and valid and act accordingly.

When this filter is called it will check if the request has been [registered]. If so then a check is done to determine if the session is valid.

If the session is valid then the request method is checked. If it's not a GET or HEAD request the authenticity token must be checked for validity. If the token is invalid then an error is returned to the client.

If the session is invalid or not present then the user is logged in as the [anonymous user] and given the anonymous session ID.

This filter also updates the anonymous session if it is more than an hour old.

See [Authentication] for more information on sessions and the authentication process.

### Usage

This filter is intended to be used prior to the request being handled so that only authenticated users have their requests handled. This means that `qc::filter_authenticate` should be registered with Naviserver during `postauth` but never for `trace`.

### Examples

```tcl
foreach http_method [list GET HEAD POST] {
    ns_register_filter postauth $http_method /* qc::filter_authenticate
}
```


qc::filter_http_request_validate
-----------------------------

The task of this filter is to check that the request and connection URL are both valid i.e. well formed.

If either the request or the URL are invalid then a `400 Bad Request` is returned to the client with a message explaining which part was not valid.

### Usage

This filter is intended to be used prior to the request being handled and ideally before any other filters. Pre-authorization is the suggested time to use this filter so that invalid requests will be caught before anything else is attempted.

### Examples

```tcl
foreach http_method [list GET POST HEAD] {
    ns_register_filter preauth $http_method /* qc::filter_http_request_validate
}
```


qc::filter_file_alias_paths
---------------------------

The task of this filter is to deal with requests that are an alias for a file. For example, a request for `/foo` might be an alias and the actual file path might be `/file/foo.png`.

If the request URL is an alias for a file a symbolic link to the canonical file location is created (if it doesn't already exist) and the URL is registered for fastpath. If anything goes wrong the error is returned to the client.

### Usage

As the intention of this filter is to resolve file aliases then it should be done prior to the request being handled so that symlinks can be set up if necessary. Therefore `qc::filter_file_alias_paths` should be set up during pre-authorization or post-authorization.

### Examples

```tcl
foreach http_method [list GET POST HEAD] {
    ns_register_filter preauth $http_method /* qc::filter_file_alias_paths $http_method
}
```

Note that `qc::filter_file_alias_path` takes the HTTP method as an argument. This is so that it can register the alias on fastpath for the requested method.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[Naviserver register docs]: http://naviserver.sourceforge.net/n/naviserver/files/ns_register.html#3
[JSON response]: global-json-response.md
[registered]: registration.md
[request handler]: registration.md
[custom validation handler]: registration.md
[anonymous user]: auth.md
[Authentication]: auth.md
