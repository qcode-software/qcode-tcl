package provide qcode 1.17
package require doc
namespace eval qc {}

proc qc::reload {{dir ""}} {
    if { $dir eq "" } {
	set dir [ns_library private]
    }
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

