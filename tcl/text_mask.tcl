proc qc::text_mask { text values } {
    #| Mask any values in text that match any of the values in the list.
    set map [list]
    foreach value $values {
        lappend map $value "***MASKED***"
    }
    return [string map $map $text]
}