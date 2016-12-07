qc::response data
====

part of [Connection Response API](../response_api.md)

Usage
-----
`qc::reponse data data_tson`

Description
-----------
Sets the data property for the [connection response](../connection-response.md).

Requires tson.

Example
-------

```tcl
% set tson_data [qc::tson_object product_code ABC qty 5]
% qc::response data $tson_data
```

Response as JSON:

```JSON
{
  "status": "valid",
  "record": {},
  "message": {},
  "action": {},
  "data": {
      "product_code": "ABC",
      "qty": 5
  }
}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"