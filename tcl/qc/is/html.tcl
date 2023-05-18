proc qc::is::html {text} {
    #| Checks if the given text contains valid html.
    try {
        # wrap the text up in <root> to preserve text outwith the html
        set text [qc::h root $text]
        set doc [dom parse -html $text]
        set root [$doc documentElement]
        $doc delete
        return 1
    } on error [list error_message options] {
        return 0
    }
}
