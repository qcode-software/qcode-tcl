#!/usr/bin/tclsh
#| Copy tcl files into package directory and add package provide statements

# Parse args
set from_dir [lindex $argv 0]
set to_dir [lindex $argv 1]
set package [lindex $argv 2]
set version [lindex $argv 3]
if { $argc != 4 || ![regexp {[0-9]+\.[0-9]+\.[0-9]+} $version] } {
    error "Usage: package.tcl from_dir to_dir package version"
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

foreach filename [lsort [glob $from_dir/*.tcl]] {
    write $to_dir/[file tail $filename] "package provide $package $version\n[cat $filename]"
}
