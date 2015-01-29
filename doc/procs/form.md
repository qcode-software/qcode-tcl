qc::form
===============

part of [Docs](../index.md)

Usage
-----
`form args`

Description
-----------
Creates an HTML form with an authenticity token where necessary and method overload.

Examples
--------
```tcl

% qc::form id test-form method POST action /home [h input type text name firstname placeholder "Enter your name"]
<form id="test-form" method="POST" action="/home">
  <input type="text" name="firstname" placeholder="Enter your name"/>
  <input type="hidden" name="_authenticity_token" value="34d1b62e729c581a6e239e6b3da73b200c996329"/>
</form>

% qc::form id test-form method DELETE action /home [qc::h p "Hello World"]
<form id="test-form" method="POST" action="/home">
  <p>Hello World</p>
  <input type="hidden" name="_authenticity_token" value="34d1b62e729c581a6e239e6b3da73b200c996329"/>
  <input type="hidden" value="DELETE" name="_method"/>
</form>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"