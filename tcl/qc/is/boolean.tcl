proc qc::is::boolean {bool} {
    #| Checks if the given number is a boolean.
    return [expr {[string toupper $bool] in {Y N YES NO TRUE FALSE T F 0 1}}]
}
