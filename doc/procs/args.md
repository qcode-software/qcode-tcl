qc::args
========

part of [Argument Passing in TCL](../qc/wiki/ArgPassing)

Usage
-----
`args caller_args specified_arguments`

Description
-----------
Specify the caller args to expect, then parse and assign them to variables appropriately.
        Arguments can be specified as switches, options or standard Tcl procedure arguments.

        For switches, a switch is specifed in the args_spec using "-switch_name".
        If a switch is passed by the caller, args will set the variable of that name to true if the switch is present.
        By default, if not passed, the switch variable will be undefined. (The Qcode qc::default command can be used
        to set a default value).

        For options, an option is specified in the args_spec using "-option_name default"
        If option is passed by the caller, a default value can be specified. To indicate not default is required, 
        use "-option_name ?". If a default is not specified, the option variable will be undefined. Otherwise the
        variable "option_name" is assigned to the option value.

        If switches and/or options are to be called, they must be provided before any standard arguments, but can
        otherwise be called in any order regardless of the order in which they were defined. 
        To indicate the list of options and switches is finished use --
        e.g. "-foo -bar bar_default -baz baz_default --"

        The values appearing after -- (or if no options or switches were specified) are treated as standard Tcl 
        procedure arguments.

Examples
--------
```tcl


% proc options_test {args} {
    qc::args $args -foo ? -bar 0 --
        # If called without any options, foo will be undefined, and bar will be 0.
        if { [info exists foo] } {
            return &quot;foo $foo bar $bar&quot;
        } else {
            return &quot;foo UNDEF bar $bar&quot;
        }
  }

    % options_test
    foo UNDEF bar 0

% options_test -foo 999 -bar 999
    foo 999 bar 999

% proc switch_test {args} {
    qc::args $args -foo --
        # If called without any options, both will be undefined unless a default is manually set as in this case.
        qc::default foo false
        return &quot;foo is $foo&quot;
}

    % switch_test
    foo is false

    % switch_test -foo
    foo is true

    % proc test {args} {
        qc::args $args -foo -bar bar_default -- thud grunt
        qc::default foo false
        return &quot;foo $foo bar $bar thud $thud grunt $grunt&quot;
    }

    % test -bar 999 -foo quux quuux
    foo true bar 999 thud quux grunt quuux

    % test quux quuux
    foo false bar bar_default thud quux grunt quuux

    % test quux 
    Too few values

    % test quux quuux quuuux
    Too many values; expected 2 but got 3 in &quot;quux quuux quuuux&quot;
    
    % test quux quuux -baz 999
    Illegal option &quot;baz&quot;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"