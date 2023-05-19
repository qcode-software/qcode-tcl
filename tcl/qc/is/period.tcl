proc qc::is::period {string} {
    #| Check if the given string is a period.

    if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
        # Period defined by two periods eg "Jan 2011 to March 2011"
        if { [qc::is period $period1] && [qc::is period $period2] } {
            return 1
        } else {
            return 0
        }
    }

    if { [qc::is date $string] } {
        # String is an iso date eg "2014-01-01"
        return 1
    }

    if { [regexp {^([12]\d{3})$} $string -> year] } {
        # Exact match for year eg "2006"
        return 1
    }

    set month_names {Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June}
    append month_names {|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November}
    append month_names {|Dec|December}

    set pattern [subst -nocommands -nobackslashes {($month_names)\s+([12]\d{3})$}]

    if { [regexp -nocase -- $pattern $string -> month_name year] } {
        # Exact match in format "Jan 2006"
        return 1
    }

    set pattern [subst {^($month_names)$}]

    if { [regexp -nocase -- $pattern $string -> month_name] } {
        # Exact match in format "Jan" (assume current year)
        return 1
    }

    set pattern {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names)\s+([12]\d{3})$}
    set pattern [subst -nocommands -nobackslashes $pattern]

    if { [regexp -nocase -- $pattern $string -> dom month_name year] } {
        # Exact match for castable date in format "1st Jan 2014"
        return 1
    }

    set pattern {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names)$}
    set pattern [subst -nocommands -nobackslashes $pattern]

    if { [regexp -nocase -- $pattern $string -> dom month_name] } {
        # Exact match for castable date in format "1st Jan" (assume current year)
        return 1       

    }

    set pattern {^($month_names)\s+([0-9]{1,2})(?:st|th|nd|rd)?\s+([12]\d{3})$}
    set pattern [subst -nocommands -nobackslashes $pattern]

    if { [regexp -nocase -- $pattern $string -> month_name dom year] } {
        # Exact match for castable date in format "Jan 1st 2014"
        return 1
    }

    set pattern {^($month_names)\s+([0-9]{1,2})(?:st|th|nd|rd)?$}
    set pattern [subst -nocommands -nobackslashes $pattern]

    if { [regexp -nocase -- $pattern $string -> month_name dom] } {
        # Exact match for castable date in format "Jan 1st" (assume current year)
        return 1
    }

    # could not parse string
    return 0
}
