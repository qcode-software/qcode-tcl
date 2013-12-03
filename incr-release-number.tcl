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

if { ![file exists RELEASE] } {
    puts [write RELEASE 1]
} else {
    puts [write RELEASE [expr [cat RELEASE]+1]]
}
