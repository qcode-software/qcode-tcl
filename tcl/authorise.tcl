namespace eval qc {
    namespace export authorise_token_create authorise_token
}

proc qc::authorise_token_create {args} {
    #| Create an authorisation token for this url
    # TODO change referrer to source
    qc::args2vars $args expires user_id referrer target 
    default expires "24 hours"
    default referrer [qc::conn_url]
    if { ! [info exist user_id] } {
        set user_id [auth]
    }
    if { ![regexp {^https?://} $referrer] } {
        set referrer [url_root "[qc::conn_location]/[string trimleft $referrer /]"]
    }
    if { ![regexp {^https?://} $target] } {
        set target [url_root "[qc::conn_location]/[string trimleft $target /]"]
    }
    set expiration_epoch [clock scan $expires]
    db_1row {
        select 
        sha1(concat(authorisation_key,:target,:referrer,:expiration_epoch)) as hash
        from users
        where user_id=:user_id
    }
    return "$user_id $expiration_epoch $hash"    
}

proc qc::authorise_token {} {
    #| Check the authorisation token of the current request
    #| and return the user_id if authorised
    if { ![form_var_exists authorisation_token] } {
        error "Authorisation token missing" {} AUTHORISATION
    }
    set token [form_var_get authorisation_token]

    lassign $token user_id expiration_epoch hash
    check user_id INT
    check expiration_epoch INT

    if { $expiration_epoch < [clock seconds] } {
        error "Authorisation failed. Token has expired." {} AUTHORISATION
    }

    # referrer
    set header_set_id [ns_conn headers]
    if { [ns_set ifind $header_set_id Referer] == -1 } {
        set referrer ""
    } else {
        set referrer [url_root [ns_set iget [ns_conn headers] Referer]]
    }

    set target [qc::conn_url]
    
    set qry {
        select 
        sha1(concat(authorisation_key,:target,:referrer,:expiration_epoch)) as check_hash
        from users
        where user_id=:user_id
    }
    db_0or1row $qry {
        error "Authorisation failed. No such user_id \"$user_id\"" {} AUTHORISATION
    } {
        if { $hash eq $check_hash } {
            return $user_id
        } else {
            error "Authorisation failed. Invalid hash value." {} AUTHORISATION
        }
    }
}
