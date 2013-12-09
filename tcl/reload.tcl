package provide qcode 2.6.1
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
            set fh [open $file r]
            set md5 [qc::md5 [read $fh]]
            close $fh
            
            if { ![nsv_exists tcl_lib_md5 $file] } {
                log Notice "Loading $file"
                namespace eval :: [list source $file]
                nsv_set tcl_lib_md5 $file $md5
            } elseif { $md5 ne [nsv_get tcl_lib_md5 $file] } {
                namespace eval :: [list ns_eval -sync source $file]
                nsv_set tcl_lib_md5 $file $md5
                log Notice "Reloading $file"
            } 
        }
    }
}
