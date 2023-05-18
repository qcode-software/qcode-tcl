proc qc::is::interval {text} {
    #| Checks if given text is an interval
    # (more restrictive than postgres, relax as needed)
    return \
        [regexp \
             {((^| +)(\+|-)?[0-9]+ +(year|month|week|day|hour|minute|second)s?)+$} \
             [string tolower $text]]
}
