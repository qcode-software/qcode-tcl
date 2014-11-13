qc::lpage
=========

part of [Docs](../index.md)

Usage
-----
`
        qc::lpage list page_length
    `

Description
-----------
Split list into sublists of length $page_length

Examples
--------
```tcl

% set items [list {code AA sales 9.99} {code BB sales 0} {code CC sales 100} {code DD sales 32} {code EE sales 65}]
{code AA sales 9.99} {code BB sales 0} {code CC sales 100} {code DD sales 32} {code EE sales 65}
% set page_content [qc::lpage $items 3]
{{code AA sales 9.99} {code BB sales 0} {code CC sales 100}} {{code DD sales 32} {code EE sales 65} {}}
% set pages [llength $page_content]
2
% for {set page 1} {$page<=$pages} {incr page} {
    puts "[lindex $page_content [expr {$page-1}]]"
    puts "Page $page of $pages"
    }
{code AA sales 9.99} {code BB sales 0} {code CC sales 100}
Page 1 of 2
{code DD sales 32} {code EE sales 65} {}
Page 2 of 2
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"