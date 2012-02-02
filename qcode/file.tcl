package provide qcode 1.4
package require doc
namespace eval qc {}
proc qc::file_temp {text {mode 0600}} {
    #| Write the text $text out into a temporary file
    #| and return the name of the file.
    package require fileutil
    set filename [fileutil::tempfile]
    set out [open $filename w $mode]
    puts -nonewline $out $text
    close $out
    return $filename
}

doc file_temp {
    Examples {
	% set csv {
	    Jimmy,1
	    Des,3
	    Bob,6
	}
	% file_temp $csv
	/tmp/ns.aCtGxR
    }
}
