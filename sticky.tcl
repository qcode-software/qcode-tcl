proc sticky_save {args} {
    #args $args -url ? args
    if { [form_var_exists sticky_url] } {
	set url [form_var_get sticky_url]
    } else {
	set url [url_path [ns_set iget [ns_conn headers] Referer]]
    }
    set employee_id [auth]
  
    if { [llength $args] == 0 } {
	# set all vars
	set args [uplevel 1 [list info locals]]
    }
    # set vars
    foreach name $args {
	if { [uplevel 1 [list info exists $name]] } {
	    sticky_set $employee_id $url $name [upset 1 $name]
	}
    }
}

proc sticky_get {name} {
    set employee_id [auth]
    set url [url_path [qc::conn_url]]
    db_1row {select value from sticky where employee_id=:employee_id and url=:url and name=:name}
    return $value
}

proc sticky_exists {name} {
    set employee_id [auth]
    set url [url_path [qc::conn_url]]
    db_0or1row {select value from sticky where employee_id=:employee_id and url=:url and name=:name} {
	return 0
    } {
	return 1
    }
}

proc sticky_set {employee_id url name value} {
    db_0or1row {select value as old_value from sticky where employee_id=:employee_id and url=:url and name=:name} {
	db_dml "insert into sticky [sql_insert employee_id url name value]"
    } {
	db_dml "update sticky set value=:value where employee_id=:employee_id and url=:url and name=:name"
    }
    return $value
}