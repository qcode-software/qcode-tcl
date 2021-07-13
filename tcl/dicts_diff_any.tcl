namespace eval qc {
    namespace export dicts_diff_any
}

proc qc::dicts_diff_any {left_dict right_dict} {
    #| Return the first diff found
    dict for {name value} $right_dict {
        if { ! [dict exists $left_dict $name] } {
            return "Key $name not found in left dict"
        }
        if { [dict get $left_dict $name] ne $value } {
            return "Left $name : \"[dict get $left_dict $name]\" Right $name : \"$value\""
        }
    }
    dict for {name value} $left_dict {
        if { ! [dict exists $right_dict $name] } {
            return "Key $name not found in right dict"
        }
        if { [dict get $left_dict $name] ne $value } {
            return "Left $name : \"[dict get $left_dict $name]\" Right $name : \"$value\""
        }
    }
}
