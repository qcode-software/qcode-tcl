# Argument Passing in Tcl

Arguments to a proc are just a list and TCL allows the use of the args argument to access a variable length list of arguments to the proc.

Different interpretations of the args list allows us to build different mechanisms for passing arguments
* Pass by Value
* Pass by Reference
* Pass by Name
* Pass by Dict
* Pass by Dict ~ Tilde Shorthand

### Pass by Value - the standard TCL way

TCL procs pass values to procedures using an ordered sequence.


Assignment of values to the argument variables is made by matching the value to the corresponding variable in the sequence of arguments.

	 
	# Pass by Value
	proc volume {radius length} {
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume $radius $length
	50.24
	 

### Pass by Reference

Upvar can be used to reference a variable in the caller's namespace.


The local and callers variable names can be different but here they are both the same.

Using "pass by reference" should be avoided because changes in the local proc variable will affect the caller and can lead to some unexpected bugs. 


	 
	# Pass by Reference
	proc volume {radiusVar lengthVar} {
	     upvar 1 $radiusVar radius
	     upvar 1 $lengthVar length
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume radius length
	50.24
	 
This technique can be generalised to handle any sequence of arguments.
	 
	proc volume {args} {
	     foreach varName $args {upvar 1 $varname $varName}
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 3
	% set length 4
	% volume radius length
	50.24
	 

### Pass by Name
Here the local variables are initially set to hold the same value as 
the caller's variables. 
This technique ensures that changes to the local variable do not affect the caller.
	 
	# Pass by name
	proc volume {radiusVar lengthVar} {
	     set radius [1 set $radiusVar](uplevel)
	     set length [1 set $lengthVar](uplevel)
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume radius length
	50.24
	 
This technique can be generalised to handle any sequence of arguments.
	 
	proc volume {args} {
	     foreach varName $args {set $varName [1 set $varName](uplevel)}
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 3
	% set length 4
	% volume radius length
	50.24
	 
### Pass by Dict
Pass by dict provides a way of passing "named arguments" where the sequence of the args does not matter.


For procs that take a long list of arguments it becomes convenient to pass a dict rather than remember the order of arguments.


It is also suitable for procs that have many optional arguments.
	 
         proc volume {dict} {
              set radius [get $dict radius](dict)
              set length [get $dict length](dict)
              return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume [radius $radius length $length](list)
	50.24
	 
It is a pain having to construct the dict when calling this proc and it would be nice to be able to write
	 
	volume [radius $radius length $length](list)
	or
	volume radius $radius length $length
	 
To allow both methods to call the proc correctly use the expansion operator {*}
which gives
	 
	proc volume {args} {
	     set radius [get $args radius](dict)
	     set length [get $args length](dict)
	     return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume {*}[radius $radius length $length](list)
	50.24
	% volume radius $radius length $length
	50.24
	 

### Pass by Dict ~ Tilde Shorthand

Instead of writing long lists of _name value name value name value ..._ pairs we can create dict's from local variables using [dict_from](qc/dict_from.html).


A qcode shorthand way of writing that uses a tilde ~ to indicate that the following list items are variable names rather than name-value pairs.
The proc can use [args2dict](qc/args2dict.html) or [args2vars](qc/args2vars.html) to parse the argument list and interpret it as a dict or a list of variable names.


	 
	proc volume {args} {
        	set dict [$args](args2dict)
                set radius [get $dict radius](dict)
                set length [get $dict length](dict)
	        return [3.14*$radius*$radius*$length](expr)
	}
	% set radius 2
	% set length 4
	% volume radius $radius length $length
	50.24
	% volume {*}[radius length](dict_from)
	50.24 
	% volume ~ radius length
	50.24
	 