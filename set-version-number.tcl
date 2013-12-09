#!/usr/bin/tclsh8.5

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

# Update all package provide statements in all *.tcl files in the tcl directory.
set package [lindex $argv 0]
set version [lindex $argv 1]
if { $argc != 2 || ![regexp {[0-9]+\.[0-9]+\.[0-9]+} $version] } {
    error "Usage: set-version-number package version"
}
set package_provide_text "package provide $package $version"
foreach filename [glob -directory tcl -nocomplain *.tcl] {
    set original_text [cat $filename]
    set modified_text $original_text
    
    foreach {match current_version} [regexp -all -inline {package +provide +[^ ]+ +([0-9]+\.[0-9]+\.[0-9])} $modified_text] {
        set modified_text [string map [list $match $package_provide_text] $modified_text]
    }

    if { $original_text ne $modified_text } {
        write $filename $modified_text
    }
}
