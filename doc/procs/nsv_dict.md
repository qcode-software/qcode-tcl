qc::nsv_dict
==============

 * [qc::nsv_dict exists variable key ?key ...?] (#qcnsv_dict-exists)
 * [qc::nsv_dict set variable key ?key ...? value] (#qcnsv_dict-set)
 * [qc::nsv_dict unset variable key ?key ...?] (#qcnsv_dict-unset)
 * [qc::nsv_dict get variable key ?key ...?] (#qcnsv_dict-get)

qc::nsv_dict exists
-------------------

Usage
-----
`qc::nsv_dict exists variable key ?key ...?`

Description
-----------
Returns Boolean indicating whether the given key (or path of keys through a set of nested dictionaries) exists in the given nsv array. 

Examples
--------
```tcl

% nsv_array get shopping_list
produce {carrots 5 potatoes 10} butchers {steak 2}
%
% nsv_dict exists shopping_list carrots
true
% 
% nsv_dict exists shopping_list onions
false
% nsv_dict exists shopping_list carrots 2
missing value to go with key
```

qc::nsv_dict set
-------------------

Usage
-----
`qc::nsv_dict set variable key ?key ...? value`

Description
-----------
Sets/updates dictionary value corresponding to a given key in a nsv_array.
When multiple keys are present, this operation creates or updates a chain of nested dictionaries.Returns Boolean indicating whether the given key (or path of keys through a set of nested dictionaries) exists in the given nsv array. 

Examples
--------
```tcl

% nsv_dict set shopping_list produce carrots 5
1
% nsv_array get shopping_list
produce {carrots 5}
% nsv_dict set shopping_list produce potatoes 10
1
% nsv_array get shopping_list
produce {carrots 5 potatoes 10}
%
% nsv_dict set shopping_list butchers steak 2
1
% nsv_array get shopping_list
produce {carrots 5 potatoes 10} butchers {steak 2}
```

qc::nsv_dict unset
-------------------

Usage
-----
`qc::nsv_dict unset variable key ?key ...?`

Description
-----------
Unsets a given key in dictionary stored in a nsv_array.
Where multiple keys are present, this describes a path through nested dictionaries to the mapping to remove.Returns Boolean indicating whether the given key (or path of keys through a set of nested dictionaries) exists in the given nsv array. 

Examples
--------
```tcl

% nsv_array get shopping_list
produce {carrots 5 potatoes 10} butchers {steak 2}
%
% nsv_dict unset shopping_list produce carrots
1
% 
% nsv_array get shopping_list
produce {potatoes 10} butchers {steak 2}
%
% nsv_dict unset shopping_list butchers
1
% nsv_array get shopping_list
produce {potatoes 10}
%
% nsv_dict unset shopping_list produce onions
Key "produce onions" not known in dictionary
```

qc::nsv_dict get
-------------------

Usage
-----
`qc::nsv_dict get variable key ?key ...?`

Description
-----------
Retrieve the value corresponding to a dictionary key stored in a nsv_array.

Examples
--------
```tcl

% nsv_dict get shopping_list produce
carrots 5 potatoes 10
%
% nsv_dict get shopping_list produce carrots
5
% 
% nsv_dict get shopping_list produce onions
Key "produce onions" not known in dictionary
```
----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
