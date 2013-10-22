package provide qcode 2.0
package require doc
namespace eval qc {}

proc qc::reload {args} {
    if {[llength $args]==0} {
        set args [nsv_array names tcl_libs]
    }
    foreach dir $args {
        nsv_set tcl_libs $dir 1
        set files [glob -nocomplain [file join $dir *.tcl]]
        foreach file $files {
            if { [nsv_exists mtimes $file] && [file mtime $file]!=[nsv_get mtimes $file] } {
                namespace eval :: [list ns_eval -sync source $file]
                nsv_set mtimes $file [file mtime $file]
                log Notice "Reloading $file"
            } else {
                #log Notice "Loading $file"
                namespace eval :: [list source $file]
                nsv_set mtimes $file [file mtime $file]
            }
        }
    }
}
