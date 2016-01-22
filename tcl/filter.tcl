namespace eval qc {
    namespace export filter_validate filter_authenticate filter_http_request_validate filter_file_alias_path file_alias_path_exists file_alias_path_new file_alias_path2file_id file_alias_path_update file_alias_path_delete filter_handler_exists filter_fastpath_gzip filter_set_expires
}

proc qc::filter_validate {event {error_handler qc::error_handler}} {
    #| Matches the URL to a handler and validates the form data if the method is a type of POST.
    # Default to qc::error_handler
    if {$error_handler eq ""} {
        set error_handler qc::error_handler
    }
    ::try {
        set url_path [qc::conn_path]
        set method [string toupper [qc::conn_method]]

        if { $method eq "VALIDATE" } {
            # Client requested only a validation service
            
            if { [qc::registered VALIDATE $url_path] } {
                set validate_method VALIDATE
            } elseif { [qc::registered GET $url_path] } {
                # Check if we can use a GET handler as a substitute
                # TODO check for any registered handler to be used as substitute.
                set validate_method GET
            } elseif { [qc::registered POST $url_path] } {
                set validate_method POST
            } else {
                error "Cannot validate \"$url_path\" because there is no registered service for the path." {} NOT_FOUND
            }

            if { [qc::handlers validate2model $validate_method $url_path]
                 && [qc::handlers validation exists $validate_method $url_path] } {
                # Passed data model validation check custom validation
                qc::handlers validation call $validate_method $url_path
            }

            # Return the results of validation to the client
            qc::return_response
            return "filter_return"
        } elseif { [qc::registered $method $url_path] } {
            # Validate and if invalid return the response otherwise continue as normal

            if {[qc::handlers validate2model $method $url_path]
                 && [qc::handlers validation exists $method $url_path] } {
                # Passed data model validation check custom validation
                qc::handlers validation call $method $url_path
            }
            
            if { [qc::response status get] eq "invalid" } {
                # Validation failed
                if { [qc::conn_open] && ![qc::conn_response_headers_sent] } {
                    # Inform the client
                    qc::return_response
                }
                return "filter_return"
            }
        }
        
        # Validation successful or url_path doesn't require validation.
        return "filter_ok"
    } on error [list error_message options] {
        $error_handler $error_message $options
        return "filter_return"
    }
}

proc qc::filter_authenticate {event args} {
    #| Checks if session and authentication token are valid.
    # Default to qc::error_handler
    args $args -login_url "/user/login" -relogin_url "/user/session-expired" -reauth_expired_session -error_handler qc::error_handler -- 

    set url_path [qc::conn_path]
    set method [string toupper [qc::conn_method]]
    ::try {
        if { [qc::registered $method $url_path] } {
            # The method url_path has been registered
            if { ![qc::cookie_exists session_id] || ![qc::session_exists [qc::session_id]] } {
                # No session cookie or session doesn't exist - implicitly log in as anonymous user.
                global session_id current_user_id
                set current_user_id [qc::anonymous_user_id]
                set session_id [qc::anonymous_session_id]
                qc::cookie_set session_id $session_id
                qc::cookie_set authenticity_token [qc::session_authenticity_token $session_id] http_only false
            }

            if { $method in [list "GET" "HEAD"] && [qc::session_user_id [qc::session_id]] == [qc::anonymous_user_id] && [qc::session_id] != [qc::anonymous_session_id] } {
                # GET/HEAD request for anonymous session - roll session after 1 hour
                global session_id current_user_id
                set current_user_id [qc::anonymous_user_id]
                set session_id [qc::anonymous_session_id]
                qc::cookie_set session_id $session_id
                qc::cookie_set authenticity_token [qc::session_authenticity_token $session_id] http_only false
            }

            if { [qc::session_valid [qc::session_id]] } {
                # Valid session - refresh session
                qc::session_update [qc::session_id]
            } else {
                # Expired session (normal user) - implicitly log in as anonymous user and optionally redirect to login forms
                set expired_user_id [qc::session_user_id [qc::session_id]]
                global session_id current_user_id
                set current_user_id [qc::anonymous_user_id]
                set session_id [qc::anonymous_session_id]
                qc::cookie_set session_id $session_id
                qc::cookie_set authenticity_token [qc::session_authenticity_token $session_id] http_only false
                qc::session_update [qc::session_id]
                
                if { [qc::registered authenticate $method $url_path] && [info exists reauth_expired_session] && $expired_user_id != [qc::anonymous_user_id] } {
                    # Request (normal user) registered for authentication redirect to reauthentication page
                    db_1row {
                        select 
                        email 
                        from users
                        where user_id=:expired_user_id
                    }
                    set relogin_url [url $relogin_url login_code $email]
                    if { $method in [list "GET" "HEAD"] } {
                        # Redirect GET/HEAD requests back to this url after login
                        return_next [url $relogin_url next_url [url_here]]
                    } else {
                        # POST requests 
                        qc::response action redirect $relogin_url
                        qc::return_response
                    }
                    return "filter_return"    
                } elseif { [qc::registered authenticate $method $url_path] && $method ni [list "GET" "HEAD"]  && $expired_user_id != [qc::anonymous_user_id] } {
                    # POST request (normal user) registered for authentication - redirect to login page.
                    qc::response action redirect $login_url
                    qc::return_response
                    return "filter_return"
                }
            }

            if { [qc::registered authenticate $method $url_path] && $method ni [list "GET" "HEAD"] } {
                # POST request registered for authentication - check authenticity token
                set header_authenticity_token [qc::http_header_get X-Authenticity-Token]
                set form_authenticity_token ""
                set authenticity_token [qc::session_authenticity_token [qc::session_id]]
                set form_dict [qc::form2dict]
                if { [dict exists $form_dict _authenticity_token] } {
                    # form variable for authenticity token was given
                    set form_authenticity_token [dict get $form_dict _authenticity_token]
                }
                
                if { $header_authenticity_token eq $authenticity_token || $form_authenticity_token eq $authenticity_token } {
                    # authenticity token is valid
                    return "filter_ok"
                } elseif { $header_authenticity_token eq "" && $form_authenticity_token eq "" } {
                    # authenticity token wasn't given
                    error "Authenticity token was not found." {} AUTH
                } else {
                    # authenticity token is invalid
                    error "Authenticity token was invalid." {} AUTH
                }
            }            
        }
    } on error [list error_message options] {
        $error_handler $error_message $options
        return "filter_return"
    }
    return "filter_ok"
}

proc qc::filter_http_request_validate {event {error_handler "qc::error_handler"}} {
    #| Check that request string and connection url are both valid.
    qc::setif error_handler "" "qc::error_handler"
    ::try {
        set request [ns_conn request]
        set url [qc::conn_path]
        if { ![qc::conn_request_is_valid $request] } {
            ns_returnbadrequest "\"$request\" is not a valid request."
            return filter_return
        }
        if { ![qc::is uri $url] } {
            return [ns_returnbadrequest "\"$url\" is not a valid URL."]
            return filter_return
        }
        return filter_ok
    } on error {error_message options} {
        $error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]
        return filter_return
    }
}

proc qc::filter_file_alias_paths {event http_method {error_handler qc::error_handler}} {
    #| Preauth filter that handles file aliases
    qc::setif error_handler "" qc::error_handler
    ::try {
        set url_path [qc::conn_path]
        if { [qc::file_alias_path_exists [string trimright $url_path /]] } {
            # URL is an alias for a file
            set alias_path [string trimright $url_path /]
            set alias_file [ns_pagepath]$alias_path
            set file_id [qc::file_alias_path2file_id $alias_path]
            
            qc::db_trans {
                # Obtain db lock to prevent simultaneous requests trying to create a sym link at the same time
                qc::db_0or1row {select file_id from file where file_id=:file_id for update} {
                    return [ns_returnnotfound]
                }
                
                # Create disk cache for target file (if it doesn't exist) and get it's canonical url
                set target_path [dict get [qc::file_data [ns_pagepath]/file $file_id] url]
                set target_file [ns_pagepath]$target_path
                
                if  { ! [file exists $alias_file] } {
                    # Alias sym link doesn't exist - create it now
                    file mkdir [file dirname $alias_file]
                    file link $alias_file $target_file
                }  elseif { [file type $alias_file] eq "link" && [file type [file link $alias_file]] eq "file" && [file link $alias_file] ne $target_file } {
                    # Alias sym link exists but does not point to the correct target file - update sym link
                    file delete $alias_file
                    file mkdir [file dirname $alias_file]
                    file link $alias_file $target_file
                } 
            }

            # Register fastpath for alias_path
            ns_register_fastpath $http_method $alias_path
        }
        return filter_ok
    } on error {error_message options} {
        $error_handler $error_message [dict get $options -errorinfo] [dict get $options -errorcode]
        return filter_return
    }
}     

proc qc::file_alias_path_exists {url_path} {
    #| Check if this url path is an alias for a file
    qc::db_0or1row {
        select 
        file_id
        from file_alias_path
        where 
        url_path=:url_path
    } {
        return false
    } {
        return true
    }
}

proc qc::file_alias_path2file_id {url_path} {
    #| Convert alias_path to file_id
    qc::db_1row {
        select 
        file_id
        from file_alias_path
        where 
        url_path=:url_path
    } 
    return $file_id
}

proc qc::file_alias_path_new {url_path file_id} {
    #| Create new file_alias_path record and it's corresponding sym link
    qc::db_trans {
        qc::db_dml {lock table file_alias_path in exclusive mode}
        qc::db_dml "insert into file_alias_path [qc::sql_insert url_path file_id]"
        # Create disk cache for target file (if it doesn't exist) and get it's canonical url
        set target_path [dict get [qc::file_data [ns_pagepath]/file $file_id] url]
        set target_file [ns_pagepath]$target_path
        # Create sym link
        set alias_file [ns_pagepath]$url_path
        if { ![file exists $alias_file] } {
            # file doesn't exist - create sym link
            file mkdir [file dirname $alias_file]
            file link $alias_file $target_file
        } elseif { [file type $alias_file] ne "link" } {
            # file exists but is not a sym link - error as we can't create/update sym link
            error "Unable to create sym link \"$alias_file\" as a regular file at this file location already exists"
        } elseif { [file type [file link $alias_file]] ne "file"} {
            # sym link exists but doesn't point to a file -  error as we can't create/update sym link
            error "Unable to update sym link \"$alias_file\" as the current link target is not a regular file"
        } elseif { [file type [file link $alias_file]] eq "file" && [file link $alias_file] ne $target_file} {
            # sym link exists but doesn't point to the correct file - remove sym link and create a new one
            file delete $alias_file
            file mkdir [file dirname $alias_file]
            file link $alias_file $target_file
        } else {
            # sym link exists and already points to the correct file - nothing to do
        }
    }
}

proc qc::file_alias_path_update {url_path file_id} {
    #| Update an exisiting file alias_path record and it's corresponding sym link
    qc::db_trans {
        qc::db_1row {select url_path from file_alias_path where url_path=:url_path for update}
        qc::db_dml "update file_alias_path set [qc::sql_set file_id] where url_path=:url_path"
        # Create disk cache for target file (if it doesn't exist) and get it's canonical url
        set target_path [dict get [qc::file_data [ns_pagepath]/file $file_id] url]
        set target_file [ns_pagepath]$target_path
        # Update sym link
        set alias_file [ns_pagepath]$url_path
        if { ![file exists $alias_file] } {
            # file doesn't exist - create sym link
            file mkdir [file dirname $alias_file]
            file link $alias_file $target_file
        } elseif { [file type $alias_file] ne "link" } {
            # file exists but is not a sym link - error as we can't create/update sym link
            error "Unable to create sym link \"$alias_file\" as a regular file at this file location already exists"
        } elseif { [file type [file link $alias_file]] ne "file"} {
            # sym link exists but doesn't point to a file -  error as we can't create/update sym link
            error "Unable to update sym link \"$alias_file\" as the current link target is not a regular file"
        } elseif { [file type [file link $alias_file]] eq "file" && [file link $alias_file] ne $target_file} {
            # sym link exists but doesn't point to the correct file - remove sym link and create a new one
            file delete $alias_file
            file mkdir [file dirname $alias_file]
            file link $alias_file $target_file
        } else {
            # sym link exists and already points to the correct file - nothing to do
        }
    }
}

proc qc::file_alias_path_delete {url_path} {
    #| Delete a file alias_path record and it's corresponding sym link
    qc::db_trans {
        qc::db_1row {select url_path from file_alias_path where url_path=:url_path for update}
        qc::db_dml "delete from file_alias_path where url_path=:url_path"
        # remove sym link
        set alias_file [ns_pagepath]$url_path
        if { [file exists $alias_file] && [file type $alias_file] eq "link" && [file type [file link $alias_file]] eq "file" } {
            file delete $alias_file
        }
    }
}

proc qc::filter_fastpath_gzip {filter_when file_extensions} {
    #| Postauth filter to seed filesystem with .gz versions of static files if the client accepts gzip-ed content.
    set conn_path [qc::conn_path]
    set file_path [ns_pagepath]$conn_path
    set gzipped_file_path [ns_pagepath]${conn_path}.gz
    
    if { [ns_conn zipaccepted] \
             && ![file readable $gzipped_file_path] \
             && [file readable $file_path] \
             && ( [llength $file_extensions] == 0 || [file extension $file_path] in $file_extensions ) \
             && [file type $file_path] in [list "link" "file"] \
         } {
        ns_gzipfile $file_path $gzipped_file_path
    }
    return "filter_ok"
}

proc qc::filter_set_expires {filter_when seconds {cache_response_directive ""}} {
    #| Postauth filter to set cache control headers: Expires, & Cache-Control. 
    #| If "cache_response_directive" is specified the function adds the "max-age" header field to the response "Cache-Control" header.
    # cache_response_directive: public, private, no-cache, no-store, no-transform, must-revalidate, or proxy-revalidate
    if { $cache_response_directive ne "" } {
        ns_setexpires -cache-control $cache_response_directive $seconds
    } else {
        ns_setexpires $seconds
    }
    return "filter_ok"
}
