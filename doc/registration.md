Request Handler Registration
============================

part of [Qcode Documentation](index.md)

* * *

In order to set up handlers they must be registered.

There are two types of registration available:

* register
* validate

Register
--------

`register` is used to register a request handler.

As well as registering the handler, `register` will add the request to the databases for validation and authentication. This means that the given request will go through both validation and authentication. There currently is not a way provided to opt out of either validation or authentication when using `register`.

### Usage

```tcl
register method path {args} {
    body
}
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

Validate
--------

`validate` is used to register a custom validation handler.

These handlers are used to set up custom validation for a request. They come in useful when validation against the data model perhaps isn't possible or when a developer might want to validate some input differently.

Validation handlers are not set up to authenticate and will only be called if a request handler matching this request is also registered.

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