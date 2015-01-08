Global JSON Response
===================
part of [Qcode Documentation](index.md)

* * *

The global JSON response represents a response to be delivered to the client as JSON. It consists of three main elements:

* Record
* Messages
* Action

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

### []qc::validate2model]
This procedure validates input agains the data model and modifies the `record` portion of the response accordingly.

### Custom Validation Handlers
Custom validation handlers are used to manually validate input. As such, any manual validation should also set up the `record` portion of the response with the result of validation.

### Request Handlers
Request handlers will often want to redirect the client to another URL after handling the request and therefore should set up the `action` portion of the response.

There may also be a need to feed back some information to the user about the request so the `message` protion of the response should be used.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[API]: response_api.md
[qc::validate2model] procs/validate2model.md