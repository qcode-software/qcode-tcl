namespace eval qc {
    namespace export ldicts_diff_any
}

proc qc::ldicts_diff_any {left_ldict right_ldict} {
    #| Return the first diff
    set index 0
    foreach left_dict $left_ldict right_dict $right_ldict {
        set diff [dicts_diff_any $left_dict $right_dict]
        if { $diff ne "" } {
            return "Index $index: $diff"
        }
        incr index
    }

    return ""
}
