Connection Response
===================
part of [Qcode Documentation](index.md)

* * *

The connection response represents a response to be delivered to the client. It consists of five main elements:

* Status
* Record
* Messages
* Actions
* Data

### Status
The status indicates if everything was valid or if, for some reason, some element is invalid. The status should be set to `invalid` on any error such as:

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
Actions suggest what the client should do next. Each action has a single property of `value` that is a URL.

`Redirect` Go to the given URL.

`Resubmit` Resubmit the form.

### Data
Data contains action-specific response data, such as a rescource representation used to update the current page client-side.


Setting Up The Response
-----------------------

Details on setting up the response can be found in the [API].


Extending The Response
----------------------

The response can be extended to include more objects alongside the standard ones. See the [API] for more information.


Sensitive Information
---------------------

If there are sensitive records, such as passwords, whose values should not be echoed back to the client then the record items can be flagged as sensitive. The name, valid, and message fields of sensitive records will remain present in the response.


Returning The Response To The Client
------------------------------------

The response can be returned to the client as JSON, XML, or HTML. [`qc::return_response`] can be used to automatically decide the best format to return to the client via content negotiation otherwise [`qc::response2json`], [`qc::response2xml`] or [`qc::response2html`] can be used to generate specific formats of the response.


Usage
-----

### [qc::validate2model]
This procedure validates input against the data model and modifies the `record` object of the response accordingly.

**Note:** If the record type is `password` or `card_number` then it is automatically marked as sensitive.

### Custom Validation Handlers
Custom validation handlers are used to manually validate input. As such, any manual validation should also set up the `record` object of the response with the result of validation as well as setting the status appropriately.

### Request Handlers
Request handlers will often want to redirect the client to another URL after handling the request and therefore should set up the `action` object of the response.

There may also be a need to feedback some information to the user about the request so the `message` object of the response should be used.

Examples
-------

Following are examples of different formats of response for an invalid login attempt.

**JSON:**

```json

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
            "message": ""
        }
    },
    "message": {
        "alert": {
            "value": "Sorry, that email or password is not recognised."
        }
    },
    "action": {}
    "data": {}
}

```

**XML:**

```xml
<status>invalid</status>
<record>
  <email>
    <valid>true</valid>
    <message></message>
    <value>foo@bar.co.uk</value>
  </email>
  <password>
    <valid>true</valid>
    <message></message>
  </password>
</record>
<message>
  <alert>
    <value>Sorry, that email or password is not recognised.</value>
  </alert>
</message>
<action></action>
<data></data>
```

**HTML:**

```html

<!doctype html>
<html>
  <head>
    <title>Missing or Invalid Data</title>
    <style>
    
        .validation-response > .status,
        .validation-response > .record .field.valid,
        .validation-response > .record .field.invalid .value,
        .validation-response > .action,
        .validation-response > .extended {
            display: none;
        }
        
        .validation-response > .record .field.invalid {
            display: list-item;
            list-style-position: inside;
            margin-left: 0em;        
        }
        
        .validation-response > .message,
        .validation-response > .record,
        .validation-response-advise {
            margin-bottom: 10px;
        }
    
    </style>
  </head>
  <body>
   <h1 class="validation-response-page-title">Missing or Invalid Data</h1>
   <div id="validation_response" class="validation-response">
     <div class="status">invalid</div>
     <div class="message">
       <div class="alert">Sorry, that email or password is not recognised.</div>
     </div>
     <div class="record">
       <div id="email" class="field valid">
         <div class="value">foo@bar.co.uk</div>
         <div class="message"></div>
       </div>
       <div id="password" class="field valid">
         <div class="message"></div>
       </div>
     </div>
     <div class="action"></div>
     <div class="data"></div>
     <div class="extended"></div>
   </div>
   <div class="validation-response-advice">Please go back and try again.</div>
  </body>
</html>
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[API]: response_api.md
[qc::validate2model]: procs/validate2model.md
[`qc::response2json`]: procs/response2json.md
[`qc::response2xml`]: procs/response2xml.md
[`qc::response2html`]: procs/response2html.md
[`qc::return_response`]: procs/return_response.md