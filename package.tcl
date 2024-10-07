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

package require fileutil
set tcl_files [fileutil::findByPattern $from_dir *.tcl]

set data "package provide $package $version\n"
foreach tcl_file $tcl_files {
    append data [fileutil::cat $tcl_file]
    append data "\n"
}
set file_out [file join $to_dir "qcode-${version}.tm"]

fileutil::writeFile $file_out $data
