namespace eval qc::record {

    namespace export invalid valid remove all_valid
    namespace ensemble create

    proc valid {name value message} {
        #| Adds the given field to the record as valid. If the field already exists then updates it.
        global data
        dict set data record $name valid true
        dict set data record $name value $value
        dict set data record $name message $message
    }

    proc invalid {name value message} {
        #| Adds the given field to the record as invalid. If the field already exists then updates it.
        global data
        dict set data record $name valid false
        dict set data record $name value $value
        dict set data record $name message $message
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