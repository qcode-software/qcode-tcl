proc qc::is::safe_html {text} {
    #| Checks if the given text contains only safe html.
    try {
        # wrap the text up in <root> to preserve text outwith the html
        set text [qc::h root $text]
        set doc [dom parse -html $text]
        set root [$doc selectNodes "//* \[name() = 'root'\]"]
        
        if {$root eq ""} {
            $doc delete
            return 1
        } else {
            set safe [expr {[qc::safe_elements_check $root]
                            && [qc::safe_attributes_check $root]}]
            $doc delete
            return $safe
        }
    } on error [list error_message options] {
        return 0
    }
}
