package require tcltest
namespace import ::tcltest::configure ::tcltest::runAllTests
configure -testdir [file dirname [file normalize [info script]]]

proc tcltest::cleanupTestsHook {} {
    variable numTests
    set ::exit_code [expr {$numTests(Failed) > 0}]
}

runAllTests

exit $exit_code
