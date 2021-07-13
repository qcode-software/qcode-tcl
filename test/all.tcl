package require tcltest
namespace import ::tcltest::configure ::tcltest::runAllTests
global test_dir 
set test_dir [file dirname [file normalize [info script]]]
configure -testdir $test_dir

# overwrite runAllTests with 8.6.9 version
if { [package vcompare [info patchlevel] 8.6.9] < 0 } {
    proc tcltest::runAllTests { {shell ""} } {
        variable testSingleFile
        variable numTestFiles
        variable numTests
        variable failFiles
        variable DefaultValue

        FillFilesExisted
        if {[llength [info level 0]] == 1} {
            set shell [interpreter]
        }

        set testSingleFile false

        puts [outputChannel] "Tests running in interp:  $shell"
        puts [outputChannel] "Tests located in:  [testsDirectory]"
        puts [outputChannel] "Tests running in:  [workingDirectory]"
        puts [outputChannel] "Temporary files stored in\
	    [temporaryDirectory]"

        # [file system] first available in Tcl 8.4
        if {![catch {file system [testsDirectory]} result]
	    && ([lindex $result 0] ne "native")} {
            # If we aren't running in the native filesystem, then we must
            # run the tests in a single process (via 'source'), because
            # trying to run then via a pipe will fail since the files don't
            # really exist.
            singleProcess 1
        }

        if {[singleProcess]} {
            puts [outputChannel] \
		"Test files sourced into current interpreter"
        } else {
            puts [outputChannel] \
		"Test files run in separate interpreters"
        }
        if {[llength [skip]] > 0} {
            puts [outputChannel] "Skipping tests that match:  [skip]"
        }
        puts [outputChannel] "Running tests that match:  [match]"

        if {[llength [skipFiles]] > 0} {
            puts [outputChannel] \
		"Skipping test files that match:  [skipFiles]"
        }
        if {[llength [matchFiles]] > 0} {
            puts [outputChannel] \
		"Only running test files that match:  [matchFiles]"
        }

        set timeCmd {clock format [clock seconds]}
        puts [outputChannel] "Tests began at [eval $timeCmd]"

        # Run each of the specified tests
        foreach file [lsort [GetMatchingFiles]] {
            set tail [file tail $file]
            puts [outputChannel] $tail
            flush [outputChannel]

            if {[singleProcess]} {
                if {[catch {
                    incr numTestFiles
                    uplevel 1 [list ::source $file]
                } msg]} {
                    puts [outputChannel] "Test file error: $msg"
                    # append the name of the test to a list to be reported
                    # later
                    lappend testFileFailures $file
                }
                if {$numTests(Failed) > 0} {
                    set failFilesSet 1
                }
            } else {
                # Pass along our configuration to the child processes.
                # EXCEPT for the -outfile, because the parent process
                # needs to read and process output of children.
                set childargv [list]
                foreach opt [Configure] {
                    if {$opt eq "-outfile"} {continue}
                    set value [Configure $opt]
                    # Don't bother passing default configuration options
                    if {$value eq $DefaultValue($opt)} {
			continue
                    }
                    lappend childargv $opt $value
                }
                set cmd [linsert $childargv 0 | $shell $file]
                if {[catch {
                    incr numTestFiles
                    set pipeFd [open $cmd "r"]
                    while {[gets $pipeFd line] >= 0} {
                        if {[regexp [join {
			    {^([^:]+):\t}
			    {Total\t([0-9]+)\t}
			    {Passed\t([0-9]+)\t}
			    {Skipped\t([0-9]+)\t}
			    {Failed\t([0-9]+)}
                        } ""] $line null testFile \
                                 Total Passed Skipped Failed]} {
                            foreach index {Total Passed Skipped Failed} {
                                incr numTests($index) [set $index]
                            }
                            if {$Failed > 0} {
                                lappend failFiles $testFile
                                set failFilesSet 1
                            }
                        } elseif {[regexp [join {
			    {^Number of tests skipped }
			    {for each constraint:}
			    {|^\t(\d+)\t(.+)$}
                        } ""] $line match skipped constraint]} {
                            if {[string match \t* $match]} {
                                AddToSkippedBecause $constraint $skipped
                            }
                        } else {
                            puts [outputChannel] $line
                        }
                    }
                    close $pipeFd
                } msg]} {
                    puts [outputChannel] "Test file error: $msg"
                    # append the name of the test to a list to be reported
                    # later
                    lappend testFileFailures $file
                }
            }
        }

        # cleanup
        puts [outputChannel] "\nTests ended at [eval $timeCmd]"
        cleanupTests 1
        if {[info exists testFileFailures]} {
            puts [outputChannel] "\nTest files exiting with errors:  \n"
            foreach file $testFileFailures {
                puts [outputChannel] "  [file tail $file]\n"
            }
        }

        # Checking for subdirectories in which to run tests
        foreach directory [GetMatchingDirectories [testsDirectory]] {
            set dir [file tail $directory]
            puts [outputChannel] [string repeat ~ 44]
            puts [outputChannel] "$dir test began at [eval $timeCmd]\n"

            uplevel 1 [list ::source [file join $directory all.tcl]]

            set endTime [eval $timeCmd]
            puts [outputChannel] "\n$dir test ended at $endTime"
            puts [outputChannel] ""
            puts [outputChannel] [string repeat ~ 44]
        }
        return [expr {[info exists testFileFailures] || [info exists failFilesSet]}]
    }
}
namespace import ::tcltest::runAllTests

# keep track of all test_dirs
global test_dirs
if { ![info exists test_dirs] } {
    set test_dirs [list]
}

# initialise summary array to keep track of aggregated test results across sub-directories
global summary
if {![info exists summary]} {
    array set ::summary \
        [dict create \
             total 0 \
             passed 0 \
             skipped 0 \
             failed 0 \
             file_count 0 \
             failed_files [list] \
            ] 
}

proc tcltest::cleanupTestsHook {} {
    variable numTests
    variable numTestFiles
    variable failFiles
    global summary

    foreach var [list Total Passed Skipped Failed] {
        incr summary([string tolower $var]) $numTests($var)
    }

    incr summary(file_count) $numTestFiles
    foreach filename $failFiles {
        lappend summary(failed_files) "$::tcltest::testsDirectory/$filename"
    }
}

if { $test_dir ni $test_dirs } {
    # prevent recursive runAllTests running test_dir tests more than once
    lappend test_dirs $test_dir

    set result [runAllTests]
} else {
    puts $::tcltest::outputChannel "Skipping test_dir: $test_dir (already executed tests)"
    set result 0
}

# exit_code
global exit_code
if { $result > 0 } {
    set exit_code 1
} elseif { ![info exists exit_code] } {
    set exit_code 0
}

# reset test_dir var which might have been overwritten by recursive nature of runnAllTests
set test_dir [file dirname [file normalize [info script]]]

if { $test_dir eq [lindex $test_dirs 0] } {
    # initial test_dir finished recursively executing tests

    # summary report of aggregated results
    puts $::tcltest::outputChannel "\n\n[string repeat = 44]\n\n"
    
    puts $::tcltest::outputChannel "Summary of Test Results"

    foreach var [list "Total" "Passed" "Skipped" "Failed"] {
        puts -nonewline $::tcltest::outputChannel \
            "\t${var}\t$::summary([string tolower $var])"
    }

    puts "\n\nSourced $::summary(file_count) Test Files."

    if { [llength $::summary(failed_files)] > 0 } {
        puts $::tcltest::outputChannel \
            "\nFiles with failing tests:\n\t[join $::summary(failed_files) "\n\t"]"
    }

    if { $exit_code > 0 && [llength $::summary(failed_files)] == 0 } {
        puts $::tcltest::outputChannel \
            "\nSome Test files exited with errors: see above sections for \"Test files exiting with errors:\""
    }
    
    puts $::tcltest::outputChannel \n\n[string repeat = 44]\n

    # exit code
    exit $exit_code
}
