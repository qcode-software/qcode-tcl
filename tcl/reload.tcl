
package require doc
namespace eval qc {
    namespace export reload
}

proc qc::reload {args} {
    if {[llength $args]==0} {
        set args [nsv_array names tcl_libs]
    }
    set reloaded false
    foreach dir $args {
        nsv_set tcl_libs $dir 1
        set files [glob -nocomplain [file join $dir *.tcl]]
        foreach file $files {
            set fh [open $file r]
            set md5 [qc::md5 [read $fh]]
            close $fh
            
            if { ![nsv_exists tcl_lib_md5 $file] } {
                log Notice "Loading $file"
                namespace eval :: [list ns_eval -sync source $file]
                nsv_set tcl_lib_md5 $file $md5
                set reloaded true

            } elseif { $md5 ne [nsv_get tcl_lib_md5 $file] } {
                namespace eval :: [list ns_eval -sync source $file]
                nsv_set tcl_lib_md5 $file $md5
                log Notice "Reloading $file"
                set reloaded true
            } 
        }
    }
    if { $reloaded } {
        foreach proc_name [info procs ::*] {
            set md5 [qc::md5 [info body ::$proc_name]]
            set pattern [string map {* \*} $proc_name]
            if { ( ! [nsv_exists tcl_proc_md5 $proc_name])
                 || $md5 ne [nsv_get tcl_proc_md5 $proc_name] } {
                log Notice "Flushing memoized proc $proc_name"
                ns_memoize_flush ::$pattern
                nsv_set tcl_proc_md5 $proc_name $md5
            }
        }
    }
}
