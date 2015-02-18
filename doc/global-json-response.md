Global JSON Response
===================
part of [Qcode Documentation](index.md)

* * *

The global JSON response represents a response to be delivered to the client as JSON. It consists of four main elements:

* Status
* Record
* Messages
* Action

### Status
The status indicates if everything was valid or if, for some reason, some element is invalid. There are 3 occasions when the status should be set to `invalid`:

* Validation failed.
* Permission check failed.
* Internal server error.

The status is set to `valid` by default.

### Record
The record consists of elements that repesent the record item. Each element represents the result of validation against the data model and has 4 properties:

`Name` The name of the element.

`Valid` The result of validation of the element against the data model.

`Value` The value of the element.

`Message` A message relating to the element to feed back to the client. E.g. That the element is invalid or why it is invalid.


### Messages
Messages allow for sending the client valuable information. There are 3 types of message with each having a single property of `value`. Only one message of each type may appear in the response.

`Alert` A warning or alert.

`Error` Indicate what went wrong.

`Notify` A notification.


### Action
Actions suggest what the client should do next. Each action has a single property of `value` that is a URL. There is currently just one action available:

`Redirect` Go to the given URL.


Setting Up The Response
-----------------------

Details on setting up the response can be found in the [API].

Usage
-----

### [qc::validate2model]
This procedure validates input against the data model and modifies the `record` object of the response accordingly.

### Custom Validation Handlers
Custom validation handlers are used to manually validate input. As such, any manual validation should also set up the `record` object of the response with the result of validation as well as setting the status appropriately.

### Request Handlers
Request handlers will often want to redirect the client to another URL after handling the request and therefore should set up the `action` object of the response.

There may also be a need to feedback some information to the user about the request so the `message` object of the response should be used.

Examples
-------

Below is an example of a JSON response for an invalid login attempt.

```JSON

{
    "status": "invalid",
    "record": {
        "email": {
            "valid": true,
            "value": "foo@bar.co.uk",
            "message": ""
        },
        "password": {
            "valid": true,
            "value": "password",
            "message": ""
        }
    },
    "message": {
        "alert": {
            "value": "Sorry, that email or password is not recognised."
        }
    },
    "action": {
        
    }
}

```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[API]: response_api.md
[qc::validate2model]: procs/validate2model.md