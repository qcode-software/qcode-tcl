
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

proc qc::file_write {filename text} {
    # Return true if file has changed by writing to it.
    if { $perms ne "" } {
	set perms [qc::format_right0 $perms 5]
    }
    if { [regexp {^([^@]+)@([^:]+[^\\]):(.+)$} $filename -> username host path]} {
	if { $perms ne "" } {
	    set handle [open "| ssh $username@$host \"touch $path && chmod $perms $path && cat > $path\"" w]
	} else {
	    set handle [open "| ssh $username@$host \"cat > $path\"" w]
	}
	puts -nonewline $handle $contents
	close $handle
	return true
    } elseif { [regexp {^([^:]+[^\\]):(.+)$} $filename -> host path] } {
	if { $perms ne "" } {
	    set handle [open "| ssh $host \"touch $path && chmod $perms $path && cat > $path\"" w]
	} else {
	    set handle [open "| ssh $host \"cat > $path\"" w]
	}
	puts -nonewline $handle $contents
	close $handle
	return true
    } else {
	if { ![file exists $filename] || [cat $filename] ne $contents || [file attributes $filename -permissions]!=$perms } { 
	    log "writing ${filename} ..."
	    set handle [open $filename w+ 00600]
	    puts -nonewline $handle $contents
	    close $handle
	    if { $perms ne "" } {
		# set file permissions
		file attributes $filename -permissions $perms
	    }
	    log "written"
	    return true
	} else {
	    return false
	}
    }
}