qc::checks
==========

part of [Docs](.)

Usage
-----
`qc::checks body`

Description
-----------
Foreach line of checks in the format <code>varName type ?type? ?type? ?errorMessage?</code>, check that the value of the local variable is of the given type or can be cast into that type. The empty string is treated as a NULL value and always treated as valid unless NOT NULL is specified in types. If the variable cannot be cast into the given type then append a message to a list of errors. Use the error message given or a default message for the given type.
    <p>
    After all checks are complete throw an error if any checks failed using combined error message.

Examples
--------
```tcl

% set order_date "never"
% set delivery_name "James Donald Alexander MacKenzie"
% set carrier ""
% checks {
    order_date DATE
    delivery_name STRING30 NOT NULL
    carrier NOT NULL "Please enter the carrier."
}
<ul>
<li>"never" is not a valid date for order_date</li>
<li>"James Donald Alexander MacKenzie" is too long for delivery_name. The maximum length is 30 characters.</li>
<li>Please enter the carrier.</li>
</ul>
% 

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"