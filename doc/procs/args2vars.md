qc::args2vars
=============

part of [Argument Passing in TCL](../qc/wiki/ArgPassing)

Usage
-----
`args2vars args ?variableName? ?variableName? ...`

Description
-----------
Parse callers args. Interpret as regular dict unless first item is ~ in which case interpret as a list of variable names to pass-by-name.
    Set all variables or just those specified.
    Ignore variable names that do not exists in the dict or do not exists in the caller's namespace.

Examples
--------
```tcl

% set foo Jimmy
% set bar Bob
% set baz Des
%
% proc test {args} {
    set varNames [args2vars $args]
    return "foo $foo bar $bar baz $baz"
  }
%
% test foo James bar Robert baz Desmond
foo James bar Robert baz Desmond

% test {*}[list foo James bar Robert baz Desmond]
foo James bar Robert baz Desmond

% test ~ foo bar baz
foo James bar Robert baz Desmond
%
% 
% proc test {args} {
    # name foo and bar as the only variables to set
    set varNames [args2vars $args foo bar]
    return "foo $foo bar $bar"
  }
%
% test foo James bar Robert baz Desmond
foo James bar Robert
%
% test ~ foo bar baz
foo James bar Robert

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"