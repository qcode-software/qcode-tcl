#!/usr/bin/tclsh8.5
#| Copy tcl files into package directory and add package provide statements

# Parse args
set package_dir [lindex $argv 0]
set package [lindex $argv 1]
set version [lindex $argv 2]
if { $argc != 3 || ![regexp {[0-9]+\.[0-9]+\.[0-9]+} $version] } {
    error "Usage: package.tcl dir package version"
}

proc cat {filename} {
    set file [open $filename r]
    set contents [read $file]
    close $file
    return $contents
}

proc write {filename string} {
    set file [open $filename w]
    puts -nonewline $file $string
    close $file
    return $string
}

set dir [file normalize [file dirname [info script]]]
foreach filename [lsort [glob $dir/tcl/*.tcl]] {
    write $package_dir/[file tail $filename] "package provide $package $version\n[cat $filename]"
}
