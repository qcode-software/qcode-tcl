namespace eval qc {
    namespace export db_trans db_trans_*
}

proc qc::db_trans {args} {
    #| Execute code within a transaction
    #| Rollback on database or tcl error
    #| Nested db_trans structures do not
    #| emulate postgres nested transactions but simply
    #| ensure code is executed in a transaction by
    #| maintaining a global db_trans_level
    args $args -db DEFAULT -- code {error_code ""}

    db_trans_start $db
    
    set return_code [ catch { uplevel 1 $code } result options ]
    
    switch $return_code {
	1 {
	    # Error
            db_trans_abort $db

	    uplevel 1 $error_code
            # Return in parent stack frame instead of here
            dict incr options -level
	}
	default {
	    # ok, return, break, continue
            db_trans_end $db

            # Preserve TCL_RETURN
            if { $return_code == 2 && [dict get $options -code] == 0 } {
                dict set options -code return
            } else {
                # Return in parent stack frame instead of here
                dict incr options -level
            }
	}
    }
    return -options $options $result
}

proc db_trans_start {{db DEFAULT}} {
    #| Start a database transaction or add a savepoint
    global db_trans_level
    if { ![info exists db_trans_level] } {
	set db_trans_level($db) 0
    }
    incr db_trans_level($db)

    set savepoint "db_trans_level_$db_trans_level($db)"

    if { $db_trans_level($db) == 1 } {
	db_dml -db $db "BEGIN WORK"
    } else {
        db_dml -db $db "SAVEPOINT $savepoint"
    }
}

proc db_trans_end {{db DEFAULT}} {
    #| Release a savepoint or commit current transaction
    global db_trans_level
    
    set savepoint "db_trans_level_$db_trans_level($db)"
    
    if { $db_trans_level($db) > 1 } {
        db_dml -db $db "RELEASE SAVEPOINT $savepoint"
    } else {
        db_dml "COMMIT WORK"
    }
    incr db_trans_level($db) -1
}

proc db_trans_abort {{db DEFAULT}} {
    #| Rollback to latest savepoint or out of transaction
    global db_trans_level
    
    set savepoint "db_trans_level_$db_trans_level($db)"
    
    if { $db_trans_level($db) > 1 } {
        db_dml -db $db "ROLLBACK TO SAVEPOINT $savepoint"
    } else {
        db_dml -db $db "ROLLBACK WORK"
    }
    incr db_trans_level($db) -1
}
