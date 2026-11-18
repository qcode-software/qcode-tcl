proc badname {a b} {
    set result [expr {$a + $b + 1000000 + 2000000 + 3000000 + 4000000 + 5000000 + 6000000 + 7000000}]
    return $result
}

proc lint_demo_untested {x} {
    #| Documented, but has no unit test and a very long line follows this comment line.
    set message "this line is deliberately much longer than the configured limit of ninety characters"
    return $message
}
