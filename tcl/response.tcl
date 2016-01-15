namespace eval qc::response {

    namespace export status record message action extend
    namespace ensemble create -unknown {
        response_subcommand_map
    }

    proc extend {name args} {
        #| Extends the JSON response with an object named $name with properties defined in $args.
        if { [llength $args] % 2 != 0 } {
            return -code error "Usage: qc::response extend name key value ?key value ...?"
        }
        global data
        dict for {key value} $args {
            dict set data $name $key $value
        }
    }

    ##################################################
    #
    # Response Status
    #
    ##################################################
    namespace eval status {

        namespace export invalid valid get
        namespace ensemble create
        
        proc invalid {} {
            #| Set the status as "invalid" for the JSON Response.
            global data
            dict set data status "invalid"
        }

        proc valid {} {
            #| Set the status as "valid" for the JSON Response.
            global data
            dict set data status "valid"
        }

        proc get {} {
            #| Gets the current status for the JSON Response.
            global data
            return [dict get $data status]
        }
    }
    
    ##################################################
    #
    # Response Record
    #
    ##################################################
    namespace eval record {

        namespace export invalid valid remove all_valid
        namespace ensemble create

        proc valid {name value {message ""}} {
            #| Adds the given field to the record as valid. If the field already exists then updates it.
            global data
            dict set data record $name valid true
            dict set data record $name value $value
            dict set data record $name message $message
        }

        proc invalid {name value message} {
            #| Adds the given field to the record as invalid. If the field already exists then updates it.
            #| Also sets the status of the response to invalid.
            global data
            dict set data record $name valid false
            dict set data record $name value $value
            dict set data record $name message $message
            qc::response status invalid
        }

        proc remove {name} {
            #| Removes the field with the given name from the record.
            global data
            dict unset data record $name
        }
        
        proc all_valid {} {
            #| Return whether the record is all valid.
            global data
            set values {}
            if {[info exists data] && [dict exists $data record]} {
                dict for {field dict} [dict get $data record] {
                    lappend values [dict get $dict valid]
                }
                return [expr [join $values " && "]]
            } else {
                return true
            }
        }
    }

    ##################################################
    #
    # Response Message
    #
    ##################################################
    namespace eval message {

        namespace export notify alert error
        namespace ensemble create

        proc notify {message} {
            #| Sets the notify property with the given message.
            global data
            dict set data message notify value $message
        }

        proc alert {message} {
            #| Sets the alert property with the given message.
            global data
            dict set data message alert value $message
        }

        proc error {message} {
            #| Sets the error property with the given message.
            global data
            dict set data message error value $message
        }
    }

    ##################################################
    #
    # Response Action
    #
    ##################################################
    namespace eval action {
        
        namespace export redirect resubmit login
        namespace ensemble create

        proc redirect {url} {
            #| Sets the redirect property with the given URL.
            global data
            reset
            dict set data action redirect value [url $url]
        }

        proc resubmit {} {
            #| Sets the resubmit action - used to resubmit the form after updating client's session/authenticity token 
            global data
            reset
            dict set data action resubmit value true
        }

        proc login {url} {
            #| Sets the login property with the given URL.
            global data
            reset
            dict set data action login value [url $url]
        }

        proc reset {} {
            #| Resets the action property of the data structure.
            global data
            if {[info exists data] && [dict exists $data action]} {
                dict unset data action
            }
        }
    }
}

proc qc::response2tson {} {
    #| Convert the global data structure into TSON.
    global data
    set record_objects [list object]
    set action_objects [list object]
    set message_objects [list object]
    set extensions [list]

    # Default status is "valid"
    set status "valid"
    ::try {
        dict for {key value} $data {
            switch $key {
                record {
                    foreach {name values} $value {
                        # Check if this is a sensitive column (should not be echo'ing back the value to the client)
                        set sensitive_column false
                        if { [qc::db_column_exists $name] } {
                            set column $name
                            set tables [qc::db_column_table $name]
                            foreach table $tables {
                                if { [qc::db_column_type $table $column] in [list password card_number] } {
                                    set sensitive_column true
                                }
                            }
                        }
                        
                        set object [list object]
                        lappend object valid [dict get $values valid]
                        lappend object message [list string [dict get $values message]]
                        if { ! $sensitive_column } {
                            lappend object value [list string [dict get $values value]]
                        }
                                                                   
                        lappend record_objects $name $object
                    }
                }
                message {
                    foreach {type val} $value {
                        lappend message_objects $type [list object value [list string [dict get $val value]]]
                    }
                }
                action {
                    foreach {type val} $value {
                        lappend action_objects $type [list object value [list string [dict get $val value]]]
                    }
                }
                status {
                    set status $value
                }
                default {
                    set object [list object]
                    foreach {name val} $value {
                        lappend object $name [list string $val]
                    }
                    lappend extensions $key $object
                }
            }
        }
        set result [list object status $status record $record_objects message $message_objects action $action_objects {*}$extensions]
        return $result
    } on error [list error_message options] {
        return -code error "Malformed data: $error_message"
    }
}

proc qc::response2json {} {
    #| Convert the global data structure into JSON.
    return [qc::tson2json [qc::response2tson]]
}

proc qc::response2xml {} {
    #| Convert the global data structure into XML.
    return [qc::tson2xml [qc::response2tson]]
}

proc qc::response2html_snippet {} {
    #| Convert the global data structure into HTML snippet.
    global data
    set record_elements {}
    set action_elements {}
    set message_elements {}
    set extended_elements {}
    # Default status is "valid"
    set status "valid"
    ::try {
        dict for {key value} $data {
            switch $key {
                record {                   
                    foreach {name values} $value {
                        # Check if this is a sensitive column (should not be echo'ing back the value to the client)
                        set sensitive_column false
                        if { [qc::db_column_exists $name] } {
                            set column $name
                            set tables [qc::db_column_table $name]
                            foreach table $tables {
                                if { [qc::db_column_type $table $column] in [list password card_number] } {
                                    set sensitive_column true
                                }
                            }
                        }
                        
                        set field_status "valid"
                        if { ! [dict get $values valid] } {
                            set field_status "invalid"
                        }
                        
                        set temp {}
                        if { ! $sensitive_column } {
                            # value
                            lappend temp [h div \
                                              class "value" \
                                              [html_escape [dict get $values value]] \
                                             ]
                        }
                        # message
                        lappend temp [h div \
                                          class "message" \
                                          [dict get $values message] \
                                         ]
                        
                        lappend record_elements [h div \
                                                     id $name \
                                                     class "field $field_status" \
                                                     [join $temp \n] \
                                                    ]                                                 
                    }
                }
                message {
                    foreach {type val} $value {
                        lappend message_elements [h div \
                                                      class "$type" \
                                                      [dict get $val value] \
                                                     ]
                    }
                }
                action {
                    foreach {type val} $value {
                        lappend action_elements [h div \
                                                     class "$type" \
                                                     [html_escape [dict get $val value]] \
                                                    ]
                    }
                }
                status {
                    set status $value
                }
                default {
                    foreach {name val} $value {
                        lappend extended_elements [h div \
                                                       id "$key" \
                                                       [html_escape $val] \
                                                      ]
                    }
                }
            }
        }
    } on error [list error_message options] {
        return -code error "Malformed data: $error_message"
    }
    
    return [h div \
                id "validation_response" \
                class "validation-response" \
                [join [list \
                           [h div class status $status] \
                           [h div class message [join $message_elements \n]] \
                           [h div class record [join $record_elements \n]] \
                           [h div class action [join $action_elements \n]] \
                           [h div class extended [join $extended_elements \n]]
                          ] \n] \
               ]
}

proc qc::response2html {} {
    #| Convert the global data structure into HTML.
    
    if {  [qc::response status get] eq "valid" } {
        # data validation passed
        set title "Data Validation Passed"

        # hide all response elements
        set css {
            .validation-response * {
                display: none;
            }
        }
    } else {
        # data validation failed
        set title "Missing or Invalid Data"
        
        # hide response elements that do not relate to invalid user input
        set css {
            .validation-response > .status,
            .validation-response > .record .field.valid,
            .validation-response > .record .field.invalid .value,
            .validation-response > .action,
            .validation-response > .extended {
                display: none;
            }
            
            .validation-response > .record .field.invalid {
                display: list-item;
                list-style-position: inside;
                margin-left: 0em;        
            }
            
            .validation-response > .message,
            .validation-response > .record,
            .validation-response-advise {
                margin-bottom: 10px;
            }
        }
    }
    
    set content ""
    append content [h h1 class "validation-response-page-title" $title]
    append content [qc::response2html_snippet]
    append content [h div class "validation-response-advice" "Please go back and try again."]
    
    set template {
        <!doctype html>
        <html>
        <head>
        <title>$title</title>
        <style>
        $css
        </style>
        </head>
        <body>
        $content
        </body>
        </html>        
    }
    
    set map {}
    lappend map \$title $title
    lappend map \$css $css
    lappend map \$content $content
    return [string map $map $template]
}
