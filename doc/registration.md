Handler and Path Registration
============================

part of [Qcode Documentation](index.md)

* * *

In order to set up handlers they must be registered.

There are two types of registration available:

* register
* validate

Register
--------

`register` is used to register a request handler or a path.

Registering will allow validation and authentication to occur through use of the filters [`qc::filter_validate`] and [`qc::filter_authenticate`] as these filters will only operate for registered paths.

### Introspection

There are two databases in place that offer introspection for determining if a path or handler has been registered.

To determine if a path has been registered [`qc::registered`] should be used.

The [Handlers API] offers introspection on request handlers as well as validation handlers.

### Usage

```tcl
register method path ?args? ?body?
```

### Examples

Basic example of a handler for request `GET /`.

```tcl
register GET / {} {
    #| Request handler for '/'
    qc::return2client html "Hello World"
}
```

Example of a POST request handler. Makes use of the [JSON response] to return a redirect action to the client.

```tcl
register POST /post {post_title, post_content} {
    set post_id [post_new $post_title $post_content]
    qc::actions redirect [url "/post/$post_id"]
}
```
Register just a path.

```tcl
register GET /home
```

Validate
--------

`validate` is used to register a custom validation handler.

These handlers are used to set up custom validation for a request. They come in useful when validation against the data model perhaps isn't possible or when a developer might want to validate some input differently.

Validation handlers are not set up to authenticate and will only be called if a request handler matching this request is also registered.

For more information regarding validation see [Validating User Input].

### Record Modification

When setting up a custom validation handler it is important to modify the record portion of the [JSON response] with the results of custom validation. If the record is not used appropriately then the client will not get the correct feedback. See the [JSON response API] for help.

### Usage

```tcl
validate method path {args} {
    body
}
```

### Examples


```tcl
validate POST /post {post_title, post_content} {
    #| Custom validation for POST /post.
    # Data model cannot validate if the content is 'safe' markdown so manually validate the content.
    set content_valid [qc::is safe_markdown $post_content]
    if {$content_valid} {
        qc::record valid post_content $post_content ""
    } else {
        # content was not safe markdown
        qc::record invalid post_content $post_content [qc::db_validation_message posts post_content]
    }
    return $content_valid
}
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[JSON response]: global-json-response.md
[JSON response API]: response_api.md
[Validating User Input]: validation.md
[`qc::registered`]: procs/registered.md
[`qc::filter_validate`]: filters.md
[`qc::filter_authenticate`]: filters.md
[Handlers API]: handlers-api.md