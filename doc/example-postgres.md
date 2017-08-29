```tcl
ns_register_proc GET /db_select.html db_select

proc db_select {} {
    set pool "main"
    set sql "select * from users"
    set db [ns_db gethandle $pool]
    
    set row [ns_db select $db $sql]
    
    set html ""
    while {[ns_db getrow $db $row]} {
        append html "<p>row: [ns_set array $row]</p>"
    }               
  
    ns_db releasehandle $db
  
    ns_return 200 text/html $html
}
```
