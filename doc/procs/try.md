qc::try
=======

part of [Docs](../index.md)

Usage
-----
`try try_code ?catch_code?`

Description
-----------
Try to execute the code <code>try_code</code> and catch any error. If an error occurs then run <code>catch_code</code>.
    <p>
    The global variables errorCode,errorInfo and errorMessage store info about the error.<br>
    [html_a errorCode {http://www.tcl.tk/man/tcl8.4/TclCmd/tclvars.htm\#M18}] - may also be user defined <br>
    [html_a errorInfo {http://www.tcl.tk/man/tcl8.4/TclCmd/tclvars.htm\#M25}] - TCL stack trace.<br>
    errorMessage - the result of executing the <code>try_code</code>
    The global errorMessage stores the result of exectuting the <code>try_code</code>.

Examples
--------
```tcl

% try {
    expr 3/0
} {
    global errorMessage errorInfo
    puts "An error was caught here."
    puts "The error message was \"$errorMessage\" with errorCode \"$errorCode\""
    puts "The stack trace was \n$errorInfo"
}

An error was caught here.
The error message was "divide by zero" with errorCode "ARITH DIVZERO {divide by zero}"
The stack trace was
divide by zero
    while executing
"expr 3/0"
    ("uplevel" body line 2)
    invoked from within
"uplevel 1 $try_code "



```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"