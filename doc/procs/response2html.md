qc::response2html
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response2html`

Description
-----------
Returns the [connection response](../connection-response.md) as HTML.
 

Examples
--------
```tcl
> qc::response record valid email "foo@bar.co.uk" ""
record {email {valid true value foo@bar.co.uk message {}}}

> qc::response record valid password "foo" ""
record {email {valid true value foo@bar.co.uk message {}} password {valid true value {foo} message {}}}

> qc::response status invalid
record {email {valid true value foo@bar.co.uk message {}} password {valid true value {} message {}}} status invalid

> qc::response message alert "Sorry, that email or password is not recognised."
record {email {valid true value foo@bar.co.uk message {}} password {valid true value {} message {}}} status invalid message {alert {value {Sorry, that email or password is not recognised.}}}

> qc::response record sensitive password
record {email {valid true value foo@bar.co.uk message {}} password {valid true value {} message {} sensitive true}} status invalid message {alert {value {Sorry, that email or password is not recognised.}}}

> qc::response2html
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
<h1 class="validation-response-page-title">Missing or Invalid Data</h1><div id="validation_response" class="validation-response"><div class="status">invalid</div>
<div class="message"><div class="alert">Sorry, that email or password is not recognised.</div></div>
<div class="record"><div id="email" class="field valid"><div class="value">foo@bar.co.uk</div>
<div class="message"></div></div>
<div id="password" class="field valid"><div class="message"></div></div></div>
<div class="action"></div>
<div class="extended"></div></div><div class="validation-response-advice">Please go back and try again.</div>
</body>
</html>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
