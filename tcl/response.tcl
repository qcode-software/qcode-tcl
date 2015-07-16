namespace eval qc::response {

    namespace export status record message action
    namespace ensemble create

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
        
        namespace export redirect login
        namespace ensemble create

        proc redirect {url} {
            #| Sets the redirect property with the given URL.
            global data
            reset
            dict set data action redirect value [url $url]
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

    ##################################################
    #
    # Response Calculated
    #
    ##################################################
    namespace eval calculated {

        namespace export field
        namespace ensemble create

        proc property {name value} {
            #| Sets a property for the calculated object with the given name and value.
            global data
            dict set data calculated $name $value
        }
    }

    ##################################################
    #
    # Response HTML
    #
    ##################################################
    namespace eval html {

        namespace export item
        namespace ensemble create

        proc property {name value} {
            #| Sets an property for the html object with the given name and value
            global data
            dict set data html $name $value
        }
    }
}
