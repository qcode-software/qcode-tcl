package provide qcode 2.5.0
package require doc
namespace eval qc {
    namespace export file_temp
}

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

doc qc::file_temp {
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
