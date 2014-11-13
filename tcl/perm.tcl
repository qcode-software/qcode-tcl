namespace eval qc {
    namespace export perm_set perm_test_employee perm_test perm perms perm_if
}

proc qc::perm_set {employee_id perm_name args} {
    #| Configure employee permissions
    #| Usage: perm_set employee_id perm_name ?method? ?method?
    set methods [string toupper $args]
    db_dml {
        -- Revoke any existing permissions on perm_name
        delete from employee_perm
        where employee_id=:employee_id 
        and perm_id in (
                        select
                        perm_id
                        from perm
                        join perm_class using (perm_class_id)
                        where perm_name=:perm_name
                        );
        
        -- Grant the specified method permissions on perm_name
        insert into employee_perm (employee_id, perm_id)
        select :employee_id, perm_id
        from perm 
        join perm_class using(perm_class_id)
        where perm_name=:perm_name
        and [qc::sql_where_in method $methods false];
    }
}

proc qc::perm_test_employee { employee_id perm_name method } {
    #| Test whether the user can perform $method on $perm_name
    #| Returns boolean
    set method [upper $method]
    db_0or1row {
        select 
        perm_id
        from employee_perm
        join perm using(perm_id)
        join perm_class using(perm_class_id)
        where 
        employee_id=:employee_id
        and perm_name=:perm_name
        and method=:method        
    } {
        return false
    } {
        return true
    }
}

proc qc::perm_test { perm_name method } {
    #| Test whether the current user can perform $method on $perm_name
    #| Returns boolean
    return [qc::perm_test_employee [qc::auth] $perm_name $method]
}

proc qc::perm { perm_name method } {
    #| Test whether the current user can perform $method on $perm_name
    #| Throws an error and sets a global ldict errorList on failure.
    if { ! [perm_test $perm_name $method] } {
        global errorList
        set errorList [list [dict create perm_name $perm_name method [upper $method]]]
	error "You do not have $method permission on $perm_name." {} PERM
    }
}

proc qc::perms { body } {
    #| Test each line of permissions
    #| Throws an error after all tests if any fail, and sets a global ldict errorList
    global errorList
    set errorList {}
    set error_messages {}
    set lines [split $body \n]
    foreach line $lines {
        set line [string trim $line]
        if {$line ne ""} {
            set perm_name [lindex [split $line " "] 0]
            set method [lindex [split $line " "] 1]
            if { ! [perm_test $perm_name $method] } {
                lappend errorList [dict create perm_name $perm_name method [upper $method]]
                lappend error_messages "You do not have $method permission on $perm_name."
            }
        }
    }
    if { $errorList ne {} } {
        error [html_list $error_messages] {} PERM
    }
}

proc qc::perm_if {perm_name method if_code {. else} {else_code ""} } {
    #| Evaluate if_code if current user has permission else else_code
    if { [perm_test $perm_name $method] } {
	uplevel 1 $if_code
    } elseif {[ne $else_code ""]} {
	uplevel 1 $else_code
    }
}

proc qc::perm_category_add {category} {
    #| Helper proc to create new permission category
    db_trans {
        set perm_category_id [db_seq perm_category_id_seq]
        db_dml {
            insert into perm_category
            (perm_category_id, description)
            values
            (:perm_category_id, :category)
        }
    }
}

proc qc::perm_add {perm_name description category args} {
    #| Helper proc to create new permissions
    db_trans {
        db_dml {lock table perm_category in exclusive mode}
        db_dml {lock table perm_class in exclusive mode}
        db_dml {lock table perm in exclusive mode}

        # Perm Category
        db_1row {
            select 
            perm_category_id
            from perm_category
            where description=:category
        }

        # Perm Class
        db_0or1row {
            select 
            perm_class_id
            from perm_class 
            where perm_name=:perm_name
        } {
            set perm_class_id [db_seq perm_class_id_seq]
            db_dml {
                insert into perm_class
                (perm_class_id, perm_name, description, perm_category_id)
                values
                (:perm_class_id, :perm_name, :description, :perm_category_id)
            }
        }

        # Perm Methods
        foreach perm_method $args {
            set perm_id [db_seq perm_id_seq]
            db_dml {
                insert into perm
                (perm_id, perm_class_id, method)
                values
                (:perm_id, :perm_class_id, :perm_method::perm_method)
            }
        }

    }    
}
