qc::return_response
===========

part of [Docs](../index.md)

Usage
-----
`return_response`

Description
-----------
Returns the [connection response] to the client.

This proc will content negotiate in order to return the [connection response] in a suitable format for the client.
If the client cannot accept any of the available formats then a code `406` is returned along with a message listing the available formats.

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"

[connection response]: ../connection-response.md