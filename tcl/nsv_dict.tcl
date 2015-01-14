namespace eval qc {
    namespace export nsv_dict
}

namespace eval qc::nsv_dict {
    namespace export exists set unset get
    namespace ensemble create

    proc exists {variable key args} {
        #| Returns Boolean indicating whether the given key (or path of keys through a set of nested dictionaries) exists in the given nsv array. 
        ::set keys [list $key {*}$args]
        if { ! [nsv_array exists $variable] } {
            # nsv array does not exist
            return false
        } elseif { ! [nsv_exists $variable [lindex $keys 0]] } {
            # Key doesn't exist in nsv_array
            return false
        } elseif { [llength $keys] == 1 } {
            # 1 key - we have already checked that the key exists in nsv_array
            return true
        } else {
            # Multiple keys - check the key path exists in the dictionary stored in nsv array
            return [dict exists [nsv_get $variable [lindex $keys 0]] {*}[lrange $keys 1 end]]
        }
    }

    proc set {args} {
        #| Sets/updates dictionary value corresponding to a given key in a nsv_array.
        #| When multiple keys are present, this operation creates or updates a chain of nested dictionaries.
        if { [llength $args] < 3 } {
            error "wrong # args: should be \"nsv_dict set variable key ... value\""
        }
        ::set variable [lindex $args 0]
        ::set keys [lrange $args 1 end-1]
        ::set value [lindex $args end]
        
        if { [llength $keys] == 1 } {
            # 1 key - set the value in an nsv array.
            nsv_set $variable [lindex $keys 0] $value
        } else {
            # Multiple keys - set/update dictionary in nsv array
            if { [nsv_exists $variable [lindex $keys 0]] } {
                ::set temp [nsv_get $variable [lindex $keys 0]]
            } else {
                ::set temp {}
            }
            dict set temp {*}[lrange $keys 1 end] $value
            nsv_set $variable [lindex $keys 0] $temp            
        } 
        return 1
    }

    proc unset {variable key args} {
        #| Unsets a given key in dictionary stored in a nsv_array.
        #| Where multiple keys are present, this describes a path through nested dictionaries to the mapping to remove.
        ::set keys [list $key {*}$args]
        if { ! [exists $variable {*}$keys] } {
            error "Key \"$keys\" not known in dictionary"
        } elseif { [llength $keys] == 1 } {
            # 1 key - unset the key in an nsv array.
            nsv_unset $variable [lindex $keys 0]
        } else {
            # Multiple keys - unset key path from dictionary stored in nsv_array
            ::set temp [nsv_get $variable [lindex $keys 0]]
            dict unset temp {*}[lrange $keys 1 end]
            nsv_set $variable [lindex $keys 0] $temp
        }     
        return 1   
    }

    proc get {variable key args} {
        #| Retrieve the value corresponding to a dictionary key stored in a nsv_array.
        ::set keys [list $key {*}$args]
        if { ! [exists $variable {*}$keys] } {
            error "Key \"$keys\" not known in dictionary"
        } elseif { [llength $keys] == 1 } {
            # 1 key - get value of the key in the nsv_array
            return [nsv_get $variable [lindex $keys 0]]
        } else {
            # Multiple keys - get the value corresponding to the key path of dictionary stored in nsv_array
            ::set temp [nsv_get $variable [lindex $keys 0]]
            return [dict get $temp {*}[lrange $keys 1 end]]
        }        
    }
}