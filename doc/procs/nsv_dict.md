qc::nsv_dict
==============

[qc::nsv_dict exists variable key ?key ...?] (#qcnsv_dict-exists)

qc::nsv_dict exists
-------------------

Usage
-----
`qc::nsv_dict exists variable key ?key ...?`

Description
-----------
Returns boolean indicating whether the given key (or path of keys through a set of nested dictionaries) exists in the given nsv array. 

Examples
--------
```tcl

%nsv_array get contacts
1 Daniel 2 David 3 Bernhard
%
% nsv_dict exists contacts 1
true
% 
% nsv_dict exists contacts 4
false
% nsv_dict exists contacts 1 Daniel
missing value to go with key
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
