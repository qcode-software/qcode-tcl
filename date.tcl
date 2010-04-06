# qcode
#
# Copyright (C) 2004 Bernhard van Woerden <bernhard@explosion.co.uk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /home/bernhard/cvs/exf/tcl/qc::date.tcl,v 1.4 2003/10/25 14:34:46 bernhard Exp $

proc qc::date_month_start {date} {
    #| Return the date on the 1st day of the month for date given.
    #| The date can be any valid date expression.
    return [clock format [cast_epoch $date] -format "%Y-%m-01"]
}

doc date_month_start {
    Parent date
    Examples {
	% date_month_start 2007-05-06
	% 2007-05-01
	%
	% date_month_start today
	% 2007-12-01
    }
}

proc qc::date_month_end {date} {
    #| Return the date on the last day of the month for the date given
    return [cast_date "[date_month_start $date] +1 month -1 day"]
}

doc date_month_end {
    Parent date
    Examples {
	% date_month_end 2007-05-06
	% 2007-05-31
	%
	% date_month_end today
	% 2008-02-29
    }
}

proc qc::date_year_start {date} {
    #| Return the date on the first day of the year
    return [clock format [cast_epoch $date] -format "%Y-01-01"]
}

doc date_year_start {
    Parent date
    Examples {
	% date_year_start 2007-05-06
	% 2007-01-01
	%
	% date_year_start "last year"
	% 2006-01-01
    }
}

proc qc::date_year_end {date} {
    #| Return the date on the last day of the year
    return [clock format [cast_epoch $date] -format "%Y-12-31"]
}

doc date_year_end {
    Parent date
    Examples {
	% date_year_end 2007-05-06
	% 2007-12-31
	%
	% date_year_end "last year"
	% 2006-12-31
    }
}

proc qc::date_year_iso_start {date} {
    #| Return the date on the 1st day of the ISO year for the date given.
    #| ISO Week numbers start on Monday.
    #| The first week of the year includes the first Thursday.
    #| The first week also includes the 4th Jan
    set year [qc::date_year $date]
    return [cast_date [clock scan "3 days ago" -base [clock scan "Thursday" -base [clock scan "$year-01-01"] ]]]
}

doc date_year_iso_start {
    Parent date
    Examples {
	% date_year_start 2006-05-06
	% 2006-01-02
	%
	% date_year_start "2 years ago"
	% 2005-01-03
    }
}

proc qc::date_year_iso_end {date} {
    #| Return the date on the last day of the ISO year for the date given.
    #| ISO Week numbers start on Monday
    #| The first week of the year includes the first Thursday
    set next_year [date_year "$date + 1 year"]
    return [cast_date [clock scan "4 days ago" -base [clock scan "Thursday" -base [clock scan "$next_year-01-01"]]]]
}

doc date_year_iso_end {
    Parent date
    Examples {
	% date_year_iso_end 2007-05-06
	% 2007-12-30
	%
	% date_year_iso_end "last year"
	% 2006-12-31
    }
}

proc qc::date_iso_week_start {date} {
    if { [eq [date_day_name $date] Monday] } {
	return [cast_date $date]
    } else {
	return [cast_date [clock scan "last monday" -base [cast_epoch $date]]]
    }
}

proc qc::date_iso_week_end {date} {   
    return [cast_date [clock scan "sunday" -base [cast_epoch $date]]]
}

proc qc::date_iso_week { date } {
    #| Return the ISO week number.
    return [cast_integer [clock format [cast_epoch $date] -format "%V"]]
}

proc qc::date_yesterday { date } {
    #| Return yesterday's date
    return [cast_date "$date -1day"]
}

proc qc::date_tomorrow { date } {
    #| Return tomorrow's date
    return [cast_date "$date +1day"]
}

proc qc::date_month { date } {
    #| Return the month number.
    return [cast_integer [clock format [cast_epoch $date] -format "%m"]]
}

doc date_month {
    Parent date
    Examples {
	% date_month 2007-05-06
	% 5
	%
	% date_month "last month"
	% 4
    }
}

proc qc::date_doy { date } {
    #| Return the day of year number.
    return [cast_integer [clock format [cast_epoch $date] -format "%j"]]
}

doc date_doy {
    Parent date
    Examples {
	% date_doy 2009-01-01
	% 1
	%
	% date_doy 2009-12-31
	% 365
    }
}


proc qc::date_year { date } {
    #| Return the year.
    return [clock format [cast_epoch $date] -format "%Y"]
}

doc date_year {
    Parent date
    Examples {
	% date_year 2007-05-06
	% 2007
	%
	% date_year "last year"
	% 2006
    }
}

proc qc::date_dom { date } {
    #| Return the day of the month.
    return [cast_integer [clock format [cast_epoch $date] -format "%d"]]
}

doc date_dom {
    Parent date
    Examples {
	% date_dom 2007-05-06
	% 6
	%
	% date_dom "2 days ago"
	% 4
    }
}

proc qc::date_dow { date } {
    #| Return the day of the week.
    return [cast_integer [clock format [cast_epoch $date] -format "%u"]]
}

proc qc::date_day_name { date } {
    #| Return the full day of the week as Monday,Tuesday etc
    return [clock format [cast_epoch $date] -format "%A"]
}

doc date_day_name {
    Parent date
    Examples {
	% date_day_name 2007-05-06
	% Sunday
	%
	% date_day_name "2 days ago"
	% Monday
    }
}

proc qc::date_day_shortname { date } {
    #| Return the day of the week as Mon,Tue,Wed,Thu,Fri,Sat,Sun
    return [clock format [cast_epoch $date] -format "%a"]
}

doc date_day_shortname {
    Parent date
    Examples {
	% date_day_shortname 2007-05-06
	% Sun
	%
	% date_day_shortname "2 days ago"
	% Mon
    }
}

proc qc::date_month_shortname { date } {
    #| Return the short month name Jan,Feb,Mar etc.
    return [clock format [cast_epoch $date] -format "%b"]
}

doc date_month_shortname {
    Parent date
    Examples {
	% date_month_shortname 2007-08-06
	% Aug
	%
	% date_month_shortname "2 days ago"
	% Apr
    }
}

proc qc::date_month_name { date } {
     # Return the full month name January,February,March etc.
    return [clock format [cast_epoch $date] -format "%B"]
}

doc date_month_name {
    Parent date
    Examples {
	% date_month_name 2007-08-06
	% August
	%
	% date_month_name "2 days ago"
	% April
    }
}

proc qc::date_compare { date1 date2 } {  
    #| Compare 2 date expressions and return 1,0,-1 if date1 is greater,equal or less than date2
    set epoch1 [cast_epoch $date1]
    set epoch2 [cast_epoch $date2]
    if { $epoch1 > $epoch2 } {
	return 1
    } elseif { $epoch1 == $epoch2 } {
	return 0
    } else {
	return -1
    }
}

doc date_compare {
    Parent date
    Examples {
	% date_compare 2007-08-06 2007-08-07
	% -1
	%
	% date_compare 2007-08-06 2007-08-06
	% 0
	%
	% date_compare 2007-08-06 2007-08-05
	% 1
    }
}

proc qc::date_quarter {date} {
    #| Return the quarter the date is in
    return [cast_int [expr {ceil(double([date_month $date])/3)}]]
}

doc date_quarter {
    Parent date
    Examples {
	% date_quarter 2007-08-06
	% 3
    }
}

proc qc::date_quarter_start {date} {
    #| Return the date at the beginning of the quarter
    set year  [date_year $date]
    set month [cast_int [expr {ceil(double([date_month $date])/3)*3-2}]]
    return [cast_date "$year-$month-01"]
}

doc date_quarter_start {
    Parent date
    Examples {
	% date_quarter_start 2007-08-06
	% 2007-07-01
    }
}

proc qc::date_quarter_end {date} {
    #| Return the date at the end of the quarter
    set year  [clock format [cast_epoch $date] -format %Y]
    set month [qc::cast_int [expr {ceil(double([date_month $date])/3)*3}]]
    return [cast_date [clock scan "+1 month -1 day" -base [clock scan "$year-$month-01"]]]
}

doc date_quarter_end {
    Parent date
    Examples {
	% date_quarter_end 2007-08-06
	% 2007-09-30
    }
}

proc qc::dates {from_date to_date} {
    #| Return a list of dates from $from_date to $to_date inclusive.
    set dates {}
    set date [cast_date $from_date]
    while {[date_compare $date $to_date]<1} {
	lappend dates $date
	set date [cast_date "$date +1 day"]
    }
    return $dates
}

doc dates {
    Parent date
    Examples {
	% date_dates 2007-02-25 2007-03-05
	% 2007-02-25 2007-02-26 2007-02-27 2007-02-28 2007-03-01 2007-03-02 2007-03-03 2007-03-04 2007-03-05
    }
}

proc qc::date_days {from_date to_date} {
    #| Return the number of days between from_date and to_date
    return [expr {([cast_epoch $to_date]-[cast_epoch $from_date])/(60*60*24)}]
}

doc dates {
    Parent date
    Examples {
	% date_days 2007-02-25 2007-03-05
	% 8
	% date_days 2007-02-25 2007-02-26
	% 1
    }
}

proc qc::years {from_date to_date} {
    set years {}
    for {set year [date_year $from_date]} {$year <= [date_year $to_date]} {incr year} {
	lappend years $year
    }
    return $years
}

proc qc::year_months {from_date to_date} {
    set year_months {}
    set month [date_month $from_date]
    set year [date_year $from_date]
    set to_month [date_month $to_date]
    set to_year [date_year $to_date]

    while {$year<$to_year || ($year==$to_year && $month<=$to_month) } {
	lappend year_months $year $month
	if { $month==12 } { set month 1; incr year } else { incr month }
    }
    return $year_months
}

proc qc::year_quarters {from_date to_date} {
    set year_quarters {}
    set quarter [date_quarter $from_date]
    set year [date_year $from_date]
    set to_quarter [date_quarter $to_date]
    set to_year [date_year $to_date]

    while {$year<$to_year || ($year==$to_year && $quarter<=$to_quarter) } {
	lappend year_quarters $year $quarter
	if { $quarter==4 } { set quarter 1; incr year } else { incr quarter }
    }
    return $year_quarters
}

proc qc::time_hour { datetime } {
    #| Return the hour
    return [cast_integer [clock format [cast_epoch $datetime] -format "%H"]]
}
