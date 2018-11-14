```tcl
ns_register_proc GET /db_dml.html db_dml_insert

proc db_dml_insert {} {
    set pool "main"
    set db [ns_db gethandle $pool]

    set sql "insert into users(user_id, firstname, surname) values (4,'Tony','Stark')"
    ns_db dml $db $sql
    ns_db releasehandle $db
}
```
