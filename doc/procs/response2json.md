qc::response2json
===========

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::response2json`

Description
-----------
Returns the [connection response](../connection-response.md) as JSON.
 

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

> qc::response2json
{
"status": "invalid",
"record": {
"email": {
"valid": true,
"message": "",
"value": "foo@bar.co.uk"
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
"action": {

}
}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
