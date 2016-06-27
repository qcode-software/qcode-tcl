qc::memoize

=======

part of [Docs](../index.md)

Usage
-----
`
        qc::memoize -timeout ? -expires ? script args
    `

Description
-----------
Wrapper that caches the result of script evaluation to improve performance for future evaluations.

The script result remains valid until the supplied expire time passes, or forever if not specified. 
The value for -expires can be expressed either as an absolute time (large values intrepreted as seconds since epoch) or as an seconds offset from the current time.

If two threads execute the same script and args, one will wait for the other to compute the result and store it in the cache. 
The -timeout option specifies how long to wait in seconds.

nb. currently requires ns_memoize to perform memoization.

Examples
--------
```tcl

% qc::memoize -expires 2520 -timeout 1 deep_tought "meaning of life"
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
