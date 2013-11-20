package provide qcode 2.01
package require doc
namespace eval qc {
    namespace export reload
}

proc qc::reload {args} {
    if {[llength $args]==0} {
        set args [nsv_array names tcl_libs]
    }
    foreach dir $args {
        nsv_set tcl_libs $dir 1
        set files [glob -nocomplain [file join $dir *.tcl]]
        foreach file $files {
            if { ![nsv_exists mtimes $file] } {
                ns_log Notice "Loading $file"
                namespace eval :: [list source $file]
                nsv_set mtimes $file [file mtime $file]
            } elseif { [file mtime $file]!=[nsv_get mtimes $file] } {
                namespace eval :: [list ns_eval -sync source $file]
                nsv_set mtimes $file [file mtime $file]
                ns_log Notice "Reloading $file"
            } 
        }
    }
}
