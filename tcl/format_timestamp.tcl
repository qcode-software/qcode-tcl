namespace eval qc {
    namespace export format_timestamp format_timestamp_* format_timestamp2hour
}

proc qc::format_timestamp_iso { args } {
    #| Format string as an ISO timestamp
    qc::args $args -text -html -- string
    if { [info exists text] } {
        return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]
    } else {
        return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]]
    }
}

proc qc::format_timestamptz { args } {
    #| Format string as an ISO timestamp with time zone
    qc::args $args -text -html -- string
    if { [info exists text] } {
        return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S %z"]
    } else {
        return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S %z"]]
    }
}

proc qc::format_timestamp_http { string } {
    #| Format string as http timestamp according to RFC 1123
    return [clock format [cast_epoch $string] -timezone :GMT -format "%a, %d %b %Y %H:%M:%S %Z"]
}

proc qc::format_timestamp_rel { string } {
    #| Format relative to age with date and time
    set epoch [cast_epoch $string]
    set epoch_now [clock seconds]
    # Today return time
    if { [string equal [cast_date $epoch_now] [cast_date $epoch]] } {
        return [clock format $epoch -format "%H:%M"]
    }
    # Same Week
    if { [string equal [clock format $epoch_now -format "%Y%U"] [clock format $epoch -format "%Y%U"]] } {
        return [clock format $epoch -format "%a %H:%M"]
    }
    # Same Year
    if { [string equal [clock format $epoch_now -format "%Y"] [clock format $epoch -format "%Y"]] } {
	return "[date_month_shortname $epoch] [format_ordinal [date_dom $epoch]]"
    }
    return [clock format $epoch -format "%Y-%m-%d"]
}

proc qc::format_timestamp2hour { args } {
    qc::args $args -text -html -- string
    if { [info exists text] } {
        return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M"]
    } else {
        return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M"]]
    }
}

proc qc::format_timestamp { args } {
    #| Format string as datetime for user.
    #| Will be customizable in future but at present chooses the ISO format.
    return [format_timestamp_iso {*}$args]
}

proc qc::format_timestamp_rel_age {args} {
    #| Return the approximate relative age of a timestamp
    qc::args $args -long -- timestamp
    
    set days [qc::date_days $timestamp now]
    if { $days == 0 } {
        return "today"
    }
  
    set years [expr {round ($days/365.0)}]
    # Return to the nearest year if 361 days or more have elapsed
    if { $years > 0 && $days > 360} {
        set rel_age "$years [iif {$years==1} year years]"
        if { [info exists long] } {
            append rel_age " ago"
        }
        return $rel_age
    }
  
    set months [expr {round($days/30.0)}]
    # Return to the nearest month if 30 days or more have elapsed
    if {$months > 0 && $days > 29} {
        set rel_age "$months [iif {$months==1} month months]"
        if { [info exists long] } {
            append rel_age " ago"
        }
        return $rel_age
    }

    set weeks [expr {round($days/7.0)}]
    # Return to the nearest week if 5 days or more have elapsed
    if {$weeks > 0 && $days > 5} {
        set rel_age "$weeks [iif {$weeks==1} week weeks]"
        if { [info exists long] } {
            append rel_age " ago"
        }
        return $rel_age
    }
    set rel_age "$days [iif {$days==1} day days]"
    if { [info exists long] } {
        append rel_age " ago"
    }
    return $rel_age
}

