package provide qcode 2.03
package require doc
namespace eval qc {
    namespace export format_date format_date_*
}

proc qc::format_date { date } {
    #| Format a date for the user
    #| Will be customizable in future but at present chooses the ISO format.
    return [string map [list - "&#8209;"] [clock format [cast_epoch $date] -format "%Y-%m-%d"]]
}

doc qc::format_date {
    Parent date
    Examples {
	% format_date "23rd June 2008"
	% 2008-06-23
	%
	% format_date 2/5/08
	% 2008-05-02
    }
}

proc qc::format_date_iso { date } {
    #| Format a date as an ISO 8601 string like 2006-04-28
    return [clock format [cast_epoch $date] -format "%Y-%m-%d"]
}

doc qc::format_date_iso {
    Parent date
    Examples {
	% format_date "23rd June 2008"
	% 2008-06-23
	%
	% format_date 2/5/08
	% 2008-05-02
    }
}

proc qc::format_date_uk { date } {
    #| Format a date in UK format e.g. 27/03/07
    return [clock format [cast_epoch $date] -format "%d/%m/%y"]
}

doc qc::format_date_uk {
    Parent date
    Examples {
	% format_date_uk 2008-06-23
	23/06/08
	% 
	% format_date_uk today
	17/10/07
    }
}

proc qc::format_date_uk_long { date } {
    #| Format a date in UK format with a 4 digit year e.g. 27/03/2007
    return [clock format [cast_epoch $date] -format "%d/%m/%Y"]
}

doc qc::format_date_uk_long {
    Parent date
    Examples {
	% format_date_uk 2008-06-23
	23/06/2008
	% 
	% format_date_uk today
	17/10/2007
    }
}

proc qc::format_date_rel { date } {
    #| Format the date relatively depending on age
    #| dates this month -> Wed 3rd
    #| dates this year -> JUN 3rd
    set epoch [cast_epoch $date]
    set epoch_now [clock seconds]
    # Today 
    if { [string equal [clock format $epoch_now -format "%Y-%m-%d"] [clock format $epoch -format "%Y-%m-%d"]] } {
        return "Today"
    }
    if { [string equal [clock format $epoch_now -format "%Y"] [clock format $epoch -format "%Y"]] } {
	# this year
	if { [string equal [clock format $epoch_now -format "%m"] [clock format $epoch -format "%m"]] } {
	    # same month
	    set dom [clock format $epoch -format "%e"]
	    set dow [clock format $epoch -format "%a"]
	    return "$dow [format_ordinal $dom]"; # Wed 3rd
	} else {
	    set dom [clock format $epoch -format "%e"] 
	    set mon [string toupper [clock format $epoch -format "%b"]]
	    return "$mon [format_ordinal $dom]"; # JUN 3rd
	}
    } else {
	return [clock format $epoch -format "%Y-%m-%d"]; # 2007-05-06
    }
}

doc qc::format_date_rel {
    Parent date
    Examples {
	% format_date_rel now
	Today
	% 
	% format_date_rel tomorrow
	Thu 18th
	%
	% format_date_rel "next month"
	NOV 17th
	%
	% format_date_rel "next year"
	2008-10-17
    }
}

proc qc::format_date_letter { date } {
    #| Format a date as would be used on a letter
    # 2007-04-12 -> 12th April 2007
    set epoch [cast_epoch $date]
    set dom [clock format $epoch -format "%e"] 
    return "[format_ordinal $dom] [clock format $epoch -format "%B %Y"]"
}

doc qc::format_date_letter {
    Parent date
    Examples {
	% format_date_letter now
	17th October 2007
    }
}


