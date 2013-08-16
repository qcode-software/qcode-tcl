package provide qcode 2.0
package require doc
namespace eval qc {}

doc authorisation {
    Title Authorisation
    Url {/qc/wiki/AuthorisePage}
}

proc qc::authorise_token_create {args} {
    #| Create an authorisation token for this url
    dict2vars $args expires employee_id referrer target 
    default expires "24 hours"
    default employee_id [auth]
    default referrer [conn_url]
    if { ![regexp {^https?://} $target] } {
        set target "[qc::conn_location]/[string trimleft $target /]"
    }
    set interval [expr {[clock scan $expires] - [clock seconds]}]
    set timestamp [expr {[clock seconds] / $interval}]
    db_1row {
        select 
        sha1(concat(authorisation_key,:target,:referrer,:timestamp)) as hash
        from employee
        where employee_id=:employee_id
    }
    return "$employee_id $interval $hash"
}

doc qc::authorise_token_create {
    Parent authorisation
}

proc qc::authorise_token_check {args} {
    #| Check the authorisation token of the current request
    #| and return the employee_id if authorised
    if { ![form_var_exists authorisation_token] } {
        error "Authorisation token missing" {} AUTHORISATION
    }
    set token [form_var_get authorisation_token]
    lassign $token employee_id interval hash
    check employee_id INT
    check interval INT
    # referer
    set referrer [ns_set get [ns_conn headers] Referer]
    set target [conn_url]
    set timestamp [expr {[clock seconds] / $interval}]
   
    set qry {
        select 
        sha1(concat(authorisation_key,:target,:referrer,:timestamp)) as check_hash
        from employee
        where employee_id=:employee_id
    }
    db_0or1row $qry {
        error "Authorisation failed. No such employee_id \"$employee_id\"" {} AUTHORISATION
    } {
        if { $hash eq $check_hash } {
            return $employee_id
        } else {
            error "Authorisation failed. Invalid hash value." {} AUTHORISATION
        }
    }
}

doc qc::authorise_token_check {
    Parent authorisation
}