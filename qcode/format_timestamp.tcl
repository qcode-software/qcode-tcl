package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::format_timestamp_iso { string } {
    #| Format string as an ISO timestamp 
    return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]]
}

doc qc::format_timestamp_iso {
    Examples {
	% format_timestamp_iso now
	2007-11-05 17:30:14
	%
	% format_timestamp_iso "23/5/2008 10:11:28"
	2008-05-23 10:11:28
	%
	% format_timestamp_iso "23rd June 2008 10:11"
	2008-06-23 10:11:00
    }
}

proc qc::format_timestamp_http { string } {
    #| Format string as http timestamp according to RFC 1123
    return [clock format [cast_epoch $string] -format "%a, %d %b %Y %H:%M:%S %Z"]
}
doc qc::format_timestamp_http {
    Examples {
	% format_timestamp_http now
        Tue, 12 Jun 2012 10:39:47 BST
    }
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

doc qc::format_timestamp_rel {
    Examples {
	% format_timestamp_rel now
	17:33
	%
	% format_timestamp_rel yesterday
	Sun 17:34
	%
	% format_timestamp_rel "next week"
	2007-11-12 17:34
    }
}

proc qc::format_timestamp2hour { string } {
    return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M"]]
}

proc qc::format_timestamp { string } {
    #| Format string as datetime for user.
    #| Will be customizable in future but at present chooses the ISO format.
    return [format_timestamp_iso $string]
}

doc qc::format_timestamp {
    Examples {
	% format_timestamp now
	2007-11-05 17:30:14
	%
	% format_timestamp "23/5/2008 10:11:28"
	2008-05-23 10:11:28
	%
	% format_timestamp "23rd June 2008 10:11"
	2008-06-23 10:11:00
    }
}

proc format_timestamp_rel_age {timestamp} {
    #| Return the approxate relative age of a timestamp
    set days [date_days $timestamp now]
    if { $days == 0 } {
	return "today"
    }
   
    set years [expr {$days / 365}]
    if { $years > 0 } { 
	return "$years [iif {$years==1} year years]" 
    } 
    
    set months [expr {$days / 30}] 
    if {$months > 0} {
	return "$months [iif {$months==1} month months]" 
    }

    set weeks [expr {$days / 7}]
    if {$weeks > 0} {
	return "$weeks [iif {$weeks==1} week weeks]" 
    }

    return "$days [iif {$days==1} day days]" 
}
