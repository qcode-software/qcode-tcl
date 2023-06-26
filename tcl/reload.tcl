namespace eval qc {
    namespace export reload
}
package require fileutil

proc qc::reload {args} {
    #| Source files that have changed in this project
    if {[llength $args]==0} {
        set args [nsv_array names tcl_libs]
    }
    set reloaded false
    foreach dir $args {
        nsv_set tcl_libs $dir 1
        set files [fileutil::findByPattern $dir "*.tcl"]
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
        ns_memoize_flush
    }
}
