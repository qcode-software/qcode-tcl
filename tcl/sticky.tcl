package provide qcode 2.6.3
package require doc
namespace eval qc {
    namespace export sticky_* sticky2vars
}

proc qc::sticky_save {args} {
    #| Save form_vars for the given sticky_url or referrer
    if { [form_var_exists sticky_url] } {
        set sticky_url [form_var_get sticky_url]
	if { [url_path $sticky_url] ne "" } {
            # extract path from sticky_url eg: "/sales_form.html"
            set url [url_path $sticky_url]
        } else {
            # Use sticky_url as a namespace eg: "sales_form"
            set url $sticky_url
        }
    } else {
	set url [url_path [ns_set iget [ns_conn headers] Referer]]
    }
    set employee_id [auth]
  
    if { [llength $args] == 0 } {
	# set all vars
	set args [uplevel 1 [lexclude [list info locals] sticky_url]]
    }
    # set vars
    foreach name $args {
	if { [uplevel 1 [list info exists $name]] } {
	    sticky_set $employee_id $url $name [upset 1 $name]
	}
    }
}

proc qc::sticky_get {args} {
    #| Get the saved sticky value for this name
    args $args -url ? -employee_id ? name
    default employee_id [auth]
    default url [url_path [qc::conn_url]]
    db_1row {select value from sticky where employee_id=:employee_id and url=:url and name=:name}
    return $value
}

proc qc::sticky_exists {args} {
    #| Test if a sticky value has been saved for this name
    args $args -url ? -employee_id ? name
    default employee_id [auth]
    default url [url_path [qc::conn_url]]
    db_0or1row {select value from sticky where employee_id=:employee_id and url=:url and name=:name} {
	return 0
    } {
	return 1
    }
}

proc qc::sticky_set {employee_id url name value} {
    #| Insert or Update the sticky record
    # trim whitespace
    set value [string trim $value]
    db_trans {
        db_1row {select employee_id from employee where employee_id=:employee_id for update}
        db_0or1row {select value as old_value from sticky where employee_id=:employee_id and url=:url and name=:name} {
            db_dml "insert into sticky [sql_insert employee_id url name value]"
        } {
            db_dml "update sticky set value=:value where employee_id=:employee_id and url=:url and name=:name"
        }
    }
    return $value
}

proc qc::sticky2vars { args } {
    #| Set variables corresponding to saved sticky values in the caller's namespace.
    foreach name $args {
	if { [sticky_exists $name] } {
	    upset 1 $name [sticky_get $name]
	} else {
	    if { [uplevel 1 [list info exists $name]] } {
		uplevel 1 [list unset $name]
	    }
	}
    }
}

proc qc::sticky_default {args} {
    #| Set var values in the caller's namespace using sticky values if not passed in form vars
    set url [url_path [ns_set iget [ns_conn headers] Referer]]
    foreach name $args {
	if { ![form_var_exists $name] && [sticky_exists -url $url $name]} {
	    upset 1 $name [sticky_get -url $url $name]
	}
    }
}
