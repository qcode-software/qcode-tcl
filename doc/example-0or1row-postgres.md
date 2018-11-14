```tcl
ns_register_proc GET /db_select_0or1row.html db_select_0or1row

proc db_select_0or1row {} {
    set pool "main"
    set sql "select * from users where user_id = 1"
    set db [ns_db gethandle $pool]
    
    set row [ns_db 0or1row $db $sql]
    if {$row eq ""} {
        set html "No rows matched the query"
    } else {
        set html [ns_set array $row]
    }

    ns_db releasehandle $db

    ns_return 200 text/html $html
}
```
