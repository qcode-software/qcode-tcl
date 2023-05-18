proc qc::is::time {time} {
    #| Check if the given date is a time
    #| in the form 23:59:59 or 23:59:59.01
    set pattern {^(([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]|24:00:00)(\.\d{1,6})?$}
    return [regexp $pattern $time]
}
