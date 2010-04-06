proc qc::file_temp {text} {
    #| Write the text $text out into a temporary file
    #| and return the name of the file.
    set filename [ns_mktemp /tmp/ns.XXXXXX]
    set out [open $filename w 0644]
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
