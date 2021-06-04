package require tcltest
namespace import ::tcltest::runAllTests

proc tcltest::cleanupTestsHook {} {
    variable num_tests
    set ::exit_code [expr {$num_tests(Failed) > 0}]
}

runAllTests

exit $exit_code
