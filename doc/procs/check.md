qc::check
=========

part of [Checking User Input](../qc/wiki/ValidationPage)

Usage
-----
`
	check varName type ?type? ?type? ?errorMessage?
    `

Description
-----------
Check that the value of the local variable is of a given type or can be cast into that type.<br/>If the variable cannot be cast into the given type then throw an error of type USER.<br/>Use the error message given or a default message for the given type.<br/>The empty string is treated as a NULL value and always treated as valid unless NOT NULL is specified in types.

Examples
--------
```tcl

% set order_date &quot;23rd June 2007&quot;
% check order_date DATE
2007-06-23
# The check passes and order_date is cast into the type DATE
% set order_date
2007-06-23
%
% set amount mistake
% check amount POS DECIMAL 
&quot;mistake&quot; is not a positive value for amount
%
% set qty eight
% check qty INT &quot;Please enter a whole number of days.&quot;
Please enter a whole number of days.
%
# NULL VALUES are valid unless excluded
% set surname &quot;&quot;
% check surname STRING 30
%
% check surname STRING 30 NOT NULL
surname is empty
%
# String length for use with varchar(n) database columns
# can be checked with STRING n
% set name &quot;James Donald Alexander MacKenzie&quot;
check name STRING 30
&quot;James Donald Alexander MacKenzie&quot; is too long for name. The maximum length is 30 characters.

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"