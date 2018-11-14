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

### Introspection

There are two databases in place that offer introspection for determining if a path or handler has been registered.

To determine if a path has been registered [`qc::registered`] should be used.

The [Handlers API] offers a way to check for the existence of a request handler, to call the handler, and to validate the data for a request handler against the data model.

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

Example of a POST request handler. Makes use of the [connection response] to return a redirect action to the client.

```tcl
register POST /post {post_title post_content} {
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

For more information regarding validation see [Validating User Input].

### Introspection

The [Handlers API] can be used to check for the existence of a validation handler and also to call a validation handler.

### Record Modification

When setting up a custom validation handler it is important to modify the record portion of the [connection response] with the results of custom validation. If the record is not used appropriately then the client will not get the correct feedback. See the [Connection Response API] for help.

### Usage

```tcl
validate method path {args} {
    body
}
```

### Examples


```tcl
validate POST /post {post_title post_content} {
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

Paths With Variable Elements
----------------------------

Paths may include variable aspects especially if following the RESTful approach to URLs. For example, in a blog project the URL to a specific post might be `/post/73` where the `73` is an integer that uniquely identifies that post. Other posts are uniquely identified by different IDs meaning that the last part of the URL may vary.

To handle such cases colon variables may be used when registering a handler. This means that any part of a path specified for a handler that begins with a colon `:` will be treated as a variable. If a request comes in and the best match for that request is a handler that makes use of colon variables then the variable part will be parsed from the request and passed in to the handler. This means that any variables in a path must then appear in the arguments for the handler.

### Examples

This example shows a path that has a variable element `post_id`. This handler will handle requests like in the blog example mentioned. A request for `GET /post/73` will result in this handler being called with the argument `73`.

```tcl
register GET /post/:post_id {post_id} {
    qc::return2client html [posts_get $post_id]
}
```

A handler may contain more than one colon variable:

```tcl
register GET /post/:post_id/comment/:comment_id {post_id comment_id} {
    qc::return2client html [comments_get $post_id $comment_id]
}
```

The above handler will handle requests like `GET /post/73/comment/5` with `73` and `5` being passed in as arguments.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[connection response]: connection-response.md
[Connection Response API]: response_api.md
[Validating User Input]: validation.md
[`qc::registered`]: procs/registered.md
[`qc::filter_validate`]: filters.md
[`qc::filter_authenticate`]: filters.md
[Handlers API]: handlers-api.md
