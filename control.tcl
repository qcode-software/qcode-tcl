#!/usr/bin/tclsh
#| Create debian package control file

# Parse args
set to_dir [lindex $argv 0]
set dpkg_name [lindex $argv 1]
set version [lindex $argv 2]
set release [lindex $argv 3]
set maintainer [lindex $argv 4]

if { $argc != 5 || ![regexp {[0-9]+\.[0-9]+\.[0-9]+} $version] } {
    error "Usage: control.tcl to_dir dpkg_name version release maintainer"
}

package require fileutil
set data [list "Package: $dpkg_name"]
lappend data "Version: $version-$release"
lappend data "Section: base"
lappend data "Priority: optional"
lappend data "Architecture: all"
lappend data "Depends: tcl,tcllib,html2text,curl,tclcurl"
lappend data "Maintainer: $maintainer"
lappend data "Description: QCode Tcl Debian Package"
lappend data ""

set file_out [file join $to_dir "control"]

fileutil::writeFile $file_out [join $data \n]
