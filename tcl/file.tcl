
package require doc
namespace eval qc {
    namespace export file_temp file_write
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

proc qc::file_write {filename contents {perms ""}} {
    # Return true if file has changed by writing to it.
    if { $perms ne "" } {
	set perms [qc::format_right0 $perms 5]
    }
    if { ![file exists $filename] || [qc::cat $filename] ne $contents || [file attributes $filename -permissions]!=$perms } { 
        log Debug "writing ${filename} ..."
        set handle [open $filename w+ 00600]
        puts -nonewline $handle $contents
        close $handle
        if { $perms ne "" } {
            # set file permissions
            file attributes $filename -permissions $perms
        }
        log Debug "written"
        return true
    } else {
        return false
    }
}

proc qc::cat {filename} {
    set handle [open $filename r]
    set contents [read $handle]
    close $handle
    return $contents
}