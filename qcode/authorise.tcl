package provide qcode 2.0
package require doc
namespace eval qc {}

doc authorisation {
    Title Authorisation
    Url {/qc/wiki/AuthorisePage}
}

proc qc::authorise_token_create {args} {
    #| Create an authorisation token for this url
    args $args -timestamped -referer [conn_url] -- target
    default timestamped false
    set current_employee [auth]

    set hash_values $referer
    append hash_values $target
    if { $timestamped } {
        append hash_values [expr {[clock seconds] / 10}]
    }
    db_1row {
        select sha1(authorisation_key || :hash_values) as hash
        from employee
        where employee_id=:current_employee
    }
    return $hash
}

doc qc::authorise_token_create {
    Parent authorisation
}

proc qc::authorise_token_check {args} {
    #| Check the authorisation token of the current request
    #| and return the employee_id if authorised
    args $args -no_session -timestamped --
    default no_session false timestamped false

    if { $no_session && [auth_check] } {
        return [auth]
    }

    # Get the token from the form variables
    if { ! [ns_set unique [ns_getform] authorisation_token] } {
        error "Multiple tokens in request"
    }
    set token [ns_set get [ns_getform] authorisation_token]

    # referer
    set hash_values [ns_set get [ns_conn headers] Referer]
    append hash_values [conn_url]
    if { $timestamped } {
        set hash_values_2 $hash_values
        set timestamp [expr {[clock seconds] / 10}]
        append hash_values $timestamp
        append hash_values_2 [expr {$timestamp - 1}]
        set qry {
            select employee_id
            from employee
            join (
                  select distinct coalesce(effective_employee_id, employee_id) as employee_id
                  from session
                  ) s using(employee_id)
            where (
                   :token=sha1(authorisation_key || :hash_values)
                   or
                   :token=sha1(authorisation_key || :hash_values_2)
                   )
        }
    } else {
        set qry {
            select employee_id
            from employee
            join (
                  select distinct coalesce(effective_employee_id, employee_id) as employee_id
                  from session
                  ) s using(employee_id)
            where :token=sha1(authorisation_key || :hash_values)
        }
    }
    db_0or1row $qry {
        error "Authorisation failed" {} AUTHORISATION
    } {
        return $employee_id
    }
}

doc qc::authorise_token_check {
    Parent authorisation
}