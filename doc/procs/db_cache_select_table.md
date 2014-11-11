qc::db_cache_select_table
=========================

part of [Cached Database API](../)

Usage
-----
`qc::db_cache_select_table args`

Description
-----------
Check if the results of the qry have already been saved.<br/>If never saved (or has expired due to ttl) then run the qry and place the results<br/>as a table in either db_thread_cache global array, or if ttl was specified,<br/>a time limited ns_cache cache.

Examples
--------
```tcl

% db_cache_select_table -ttl 20 {select user_id,firstname,surname from users}
% {user_id firstname surname} {73214205 Jimmy Tarbuck} {73214206 Des O'Conner} {73214208 Bob Monkhouse}

% set surname MacDonald
% db_cache_select_table -ttl [expr 60*60*60*24] {select id,firstname,surname from users where surname=:surname}
% {user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"