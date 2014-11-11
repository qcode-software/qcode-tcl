qc::args2dict
=============

part of [Argument Passing in TCL](../args.md)

Usage
-----
`args2dict args`

Description
-----------
Parse callers args. Interpret as regular dict unless first item is ~ in which case interpret as a list of variable names to pass-by-name.
    Return dict of resulting name value pairs.

Examples
--------
```tcl

% set foo Jimmy
% set bar Bob
% set baz Des
%
% proc test {args} {
    return [args2dict $args]
  }
%
% test foo James bar Robert baz Desmond
foo James bar Robert baz Desmond

% test [list foo James bar Robert baz Desmond]
foo James bar Robert baz Desmond

% test ~ foo bar baz
foo James bar Robert baz Desmond

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"