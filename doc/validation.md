Validating User Input
=====================

part of [Qcode Documentation](index.md)

* * *

Against The Data Model
----------------------

User input can be validated against the data model with very little setup using [filters] and [registration].




Legacy
------

** NOTE: This method of validation is deprecated and the above method for validation should be used. **

All user input should be checked to see that
* It can be cast into a string literal of the required type.
* Conforms to a range of acceptable values.

The [check](procs/check.md) and [checks](procs/checks.md) procs provide a way of converting and checking data and then returning useful error messages.

Data is checked against a list of TYPEs.The empty string is always valid unless the type NOT NULL is specified.

```tcl

proc user_create {name email password dob} {
    checks {
        name STRING50 NOT NULL "Please enter your name in 50 characters or fewer"
        email STRING100 EMAIL NOT NULL
        password STRING20 NOT NULL
        dob DATE
    }
    # name, email and password are all mandatory but dob is option and may be the empty string.
...
...
}

```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[filters]: filters.md
[registration]: registration.md