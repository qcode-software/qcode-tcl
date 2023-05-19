proc qc::is::timestamp { date } {
    #| Checks if the given date is a timestamp (in iso format).
    return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$} $date]   
}

proc qc::is::timestamptz {date} {
    #| Checks if the given date is a timestamp with a time zone (in iso format).
    return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\+|-)([0-9][0-9])$} $date] 
}

proc qc::is::timestamp_http {date} {
    #| Checks if the given date is an acceptable HTTP timestamp.
    #| Note although all three should be accepted, only RFC 1123 format should
    #| be generated.

    set short_day {[(Mon)|(Tue)|(Wed)|(Thu)|(Fri)|(Sat)|(Sun)]}
    set long_day {[(Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday)|}
        append long_day {(Saturday)|(Sunday)]}
    set short_month {(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)}
    set time {[0-2]\d(\:)[0-5]\d(\:)[0-5]\d}

    # RFC 1123 - Sun, 06 Nov 1994 08:49:37 GMT
    set pattern {(?x)
        $short_day[,]
        \s\d{2}\s$short_month\s\d{4}
        \s$time\s(GMT)
    }
    set pattern [subst -nobackslashes -nocommands $pattern]

    if { [regexp $pattern $date] } {
        return 1
    }

    # RFC 850 - Sunday, 06-Nov-94 08:49:37 GMT
    set pattern {(?x)
        $long_day[,]
        \s\d{2}-$short_month-\d{2}
        \s$time\s(GMT)
    }
    set pattern [subst -nobackslashes -nocommands $pattern]

    if { [regexp $pattern $date] } {
        return 1
    }

    # ANCI C - Sun Nov  6 08:49:37 1994
    set pattern {(?x)
        $short_day
        \s$short_month\s(\s|\d)\d
        \s$time\s\d{4}
    }
    set pattern [subst -nobackslashes -nocommands $pattern]

    if { [regexp $pattern $date] } {
        return 1
    }

    return 0
}
