qc::try
=======

part of [Docs](.)

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
    puts &quot;An error was caught here.&quot;
    puts &quot;The error message was \&quot;$errorMessage\&quot; with errorCode \&quot;$errorCode\&quot;&quot;
    puts &quot;The stack trace was \n$errorInfo&quot;
}

An error was caught here.
The error message was &quot;divide by zero&quot; with errorCode &quot;ARITH DIVZERO {divide by zero}&quot;
The stack trace was
divide by zero
    while executing
&quot;expr 3/0&quot;
    (&quot;uplevel&quot; body line 2)
    invoked from within
&quot;uplevel 1 $try_code &quot;



```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"