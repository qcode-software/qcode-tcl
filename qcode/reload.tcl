package provide qcode 1.1
package require doc
namespace eval qc {}
proc qc::reload {{dir ""}} {
    if { ![namespace exists qc] } {
	namespace eval qc {}
    }
    if { [eq $dir ""] } {
	set dir [ns_library private]
    }
    set files [glob -nocomplain [file join $dir *.tcl]]
    set files [concat $files [glob -nocomplain [file join $dir *.doc]]]
  
    foreach file $files {
	if { [nsv_exists mtimes $file] } {
	    if { [file mtime $file]!=[nsv_get mtimes $file] } {
		namespace eval :: [list ns_eval -sync source $file]
		
		nsv_set mtimes $file [file mtime $file]
		ns_log Notice "Reloading $file"
	    }
	} else {
	    #ns_log Notice "Loading $file"
	    namespace eval :: [list source $file]
	    nsv_set mtimes $file [file mtime $file]
	}
    }
}

