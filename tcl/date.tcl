namespace eval qc {
    namespace export date_* dates years iso_year_iso_weeks year_months year_quarters time_hour
}

proc qc::date_month_start {date} {
    #| Return the date on the 1st day of the month for date given.
    #| The date can be any valid date expression.
    return [clock format [cast_epoch $date] -format "%Y-%m-01"]
}

proc qc::date_month_end {date} {
    #| Return the date on the last day of the month for the date given
    return [cast_date "[qc::date_month_start $date] +1 month -1 day"]
}

proc qc::date_year_start {date} {
    #| Return the date on the first day of the year
    return [clock format [cast_epoch $date] -format "%Y-01-01"]
}

proc qc::date_year_end {date} {
    #| Return the date on the last day of the year
    return [clock format [cast_epoch $date] -format "%Y-12-31"]
}

proc qc::date_year_iso_start {date} {
    #| Return the date on the 1st day of the ISO year for the date given.
    #| ISO Week numbers start on Monday.
    #| The first week of the year includes the first Thursday.
    #| The first week also includes the 4th Jan
    set year [qc::date_year $date]
    return [cast_date [clock scan "3 days ago" -base [clock scan "Thursday" -base [clock scan "$year-01-01"] ]]]
}

proc qc::date_year_iso_end {date} {
    #| Return the date on the last day of the ISO year for the date given.
    #| ISO Week numbers start on Monday
    #| The first week of the year includes the first Thursday
    set next_year [date_year "$date + 1 year"]
    return [cast_date [clock scan "4 days ago" -base [clock scan "Thursday" -base [clock scan "$next_year-01-01"]]]]
}

proc qc::date_iso_year { date } {
    #| Return the ISO year.
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%G"]]
}

proc qc::date_iso_week_start {date} {
    #| Returns the date of the start of the week in which $date falls
    if { [eq [date_day_name $date] Monday] } {
	return [cast_date $date]
    } else {
	return [cast_date [clock scan "last monday" -base [cast_epoch $date]]]
    }
}

doc qc:::date_iso_week_start {
    Parent date
    Examples {
	% date_iso_week_start 2007-05-06
	% 2007-04-30
	%
	% date_iso_week_start "today"
	% 2012-08-06
    }
}

proc qc::date_iso_week_end {date} {   
    #| Returns the date of the end of the week in which $date falls
    return [cast_date [clock scan "sunday" -base [cast_epoch $date]]]
}

doc qc:::date_iso_week_end {
    Parent date
    Examples {
	% date_iso_week_end 2007-05-06
	% 2007-05-06
	%
	% date_iso_week_end "today"
	% 2012-08-12
    }
}

proc qc::date_iso_week { date } {
    #| Return the ISO week number.
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%V"]]
}

doc qc:::date_iso_week {
    Parent date
    Examples {
	% date_iso_week 2007-05-06
	% 18
	%
	% date_iso_week "today"
	% 32
    }
}

proc qc::date_yesterday { date } {
    #| Return yesterday's date
    return [cast_date "$date -1day"]
}

doc qc:::date_yesterday {
    Parent date
    Examples {
	% date_yesterday 2007-05-06
	% 2007-05-05
	%
	% date_yesterday "today"
	% 2012-08-09
    }
}

proc qc::date_tomorrow { date } {
    #| Return tomorrow's date
    return [cast_date "$date +1day"]
}

doc qc:::date_tomorrow {
    Parent date
    Examples {
	% date_tomorrow 2007-05-06
	% 2007-05-07
	%
	% date_tomorrow "today"
	% 2012-08-11
    }
}

proc qc::date_month { date } {
    #| Return the month number.
    if { [regexp {^(\d{4})-(\d{2})-(\d{2})$} $date -> year month day] } {
        return [qc::cast_integer $month]
    }
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%m"]]
}

proc qc::date_doy { date } {
    #| Return the day of year number.
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%j"]]
}

proc qc::date_year { date } {
    #| Return the year.
    if { [regexp {^(\d{4})-(\d{2})-(\d{2})$} $date -> year month day] } {
        return $year
    }
    return [clock format [cast_epoch $date] -format "%Y"]
}

proc qc::date_dom { date } {
    #| Return the day of the month.
    if { [regexp {^(\d{4})-(\d{2})-(\d{2})$} $date -> year month day] } {
        return [qc::cast_integer $day]
    }
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%d"]]
}

proc qc::date_dow { date } {
    #| Return the day of the week.
    return [qc::cast_integer [clock format [cast_epoch $date] -format "%u"]]
}

proc qc::date_day_name { date } {
    #| Return the full day of the week as Monday,Tuesday etc
    return [clock format [cast_epoch $date] -format "%A"]
}

proc qc::date_day_shortname { date } {
    #| Return the day of the week as Mon,Tue,Wed,Thu,Fri,Sat,Sun
    return [clock format [cast_epoch $date] -format "%a"]
}

proc qc::date_month_shortname { date } {
    #| Return the short month name Jan,Feb,Mar etc.
    return [clock format [cast_epoch $date] -format "%b"]
}

proc qc::date_month_name { date } {
     # Return the full month name January,February,March etc.
    return [clock format [cast_epoch $date] -format "%B"]
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

proc qc::date_quarter {date} {
    #| Return the quarter the date is in
    return [qc::cast_int [expr {ceil(double([date_month $date])/3)}]]
}

proc qc::date_quarter_start {date} {
    #| Return the date at the beginning of the quarter
    set year  [date_year $date]
    set month [qc::cast_int [expr {ceil(double([date_month $date])/3)*3-2}]]
    return [cast_date "$year-$month-01"]
}

proc qc::date_quarter_end {date} {
    #| Return the date at the end of the quarter
    set year  [clock format [cast_epoch $date] -format %Y]
    set month [qc::cast_int [expr {ceil(double([date_month $date])/3)*3}]]
    return [cast_date [clock scan "+1 month -1 day" -base [clock scan "$year-$month-01"]]]
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

proc qc::date_days {from_date to_date} {
    #| Return the number of days between from_date and to_date
    # Rounding to cope with daylight saving time, leap-seconds, etc.
    return [qc::round [expr {([cast_epoch $to_date]-[cast_epoch $from_date])/(60.0*60*24)}] 0]
}

proc qc::years {from_date to_date} {
    #| Returns list of years between from_date & to_date
    set years {}
    for {set year [date_year $from_date]} {$year <= [date_year $to_date]} {incr year} {
	lappend years $year
    }
    return $years
}

proc qc::iso_year_iso_weeks {from_date to_date} {
    # Return list of iso years/iso week pairs between from_date & to_date
    set year_weeks {}
    set week [date_iso_week $from_date]
    set year [date_iso_year $from_date]
    set to_week [date_iso_week $to_date]
    set to_year [date_iso_year $to_date]

    while {$year<$to_year || ($year==$to_year && $week<=$to_week) } {
	lappend year_weeks $year $week
	set last_week [date_iso_week [date_year_iso_end ${year}-01-01]]
	if { $week==$last_week } { set week 1; incr year } else { incr week }
    }
    return $year_weeks
}

proc qc::year_months {from_date to_date} {
    #| Returns list of iso year/iso month pairs between from_date & to_date
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
    #| Returns list of iso year/quarter pairs between from_date & to_date
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
    return [qc::cast_integer [clock format [cast_epoch $datetime] -format "%H"]]
}

