proc qc::is::safe_markdown {markdown} {
    #| Checks if the given markdown text contains HTML elements that are deemed safe.
    try {
        qc::commonmark2html $markdown
        return 1
    } on error [list error_message options] {
        return 0
    }
}
