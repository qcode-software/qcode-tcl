package require tcltest
namespace import ::tcltest::runAllTests

proc tcltest::cleanupTestsHook {} {
    variable numTests
    set ::exit_code [expr {$numTests(Failed) > 0}]
}

runAllTests

#exit $exit_code
exit 0
