qc::reponse extend
===========

part of [Global JSON Response API](../response_api.md)

Usage
-----
`qc::reponse ?extend? name key value ?key value ...?`

Description
-----------
Extends the response with an object named after the given name with properties as specified.

Nested objects are not supported.

Examples
--------
```tcl

% qc::reponse extend calculated weight 19.85

OR

% qc::response calculated weight 19.85

```

Resulting JSON:

```JSON
{
  "status": "valid",
  "record": {},
  "message": {},
  "action": {},
  "calculated": {
    "weight": 19.85
  }
}

```

-----


```tcl

qc::response test foo 1 bar two baz true

```

Resulting JSON:

```JSON
{
  "status": "valid",
  "record": {},
  "message": {},
  "action": {},
  "test": {
    "foo": 1,
    "bar": "two",
    "baz": true
  }
}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[global JSON response]: ../global-json-response.md