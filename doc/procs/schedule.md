qc::schedule
============

part of [Docs](.)

Usage
-----
`qc::schedule args`

Description
-----------
Schedule proc for execution unless already scheduled. Start schedule if it is not already running.

Examples
--------
```tcl

% schedule -thread &quot;50 seconds&quot; my_proc
% schedule -thread &quot;5 minutes&quot; my_proc foo bar
% schedule &quot;1 hour&quot; another_proc
% schedule &quot;10:15&quot; daily_tasks yellow
% schedule &quot;Monday 10:15&quot; monday_tasks

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"