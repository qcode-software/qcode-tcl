package require tcltest
package require qcode 1.7
::tcltest::configure -testdir [file dirname [file normalize [info script]]]
eval ::tcltest::configure $argv
::tcltest::runAllTests
