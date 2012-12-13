package provide qcode 1.10
package require doc
namespace eval qc {}
proc qc::ftp_open {host user password} {
    set timeout 30
    set sock [ns_sockopen $host 21]
    set ctrl_read [lindex $sock 0]
    set ctrl_write [lindex $sock 1]
    try {
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
	qc::ftp_ctrl_write $ctrl_write "USER $user" $timeout
	qc::ftp_ctrl_read $ctrl_read 3 $timeout
	qc::ftp_ctrl_write $ctrl_write "PASS $password" $timeout
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
	return [list $ctrl_read $ctrl_write]
    } {
	qc::ftp_close $ctrl_read $ctrl_write
	global errorMessage errorInfo errorCode
	error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_close {ctrl_read ctrl_write} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "QUIT" $timeout
	close $ctrl_read
	close $ctrl_write
    } {
	close $ctrl_read
        close $ctrl_write
    }
}

proc qc::ftp_pasv {ctrl_read ctrl_write} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "PASV" $timeout
	set line [qc::ftp_ctrl_read $ctrl_read 2 $timeout]
    } {
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
    if { [regexp -- {([0-9]+),([0-9]+),([0-9]+),([0-9]+),([0-9]+),([0-9]+)} $line match a1 a2 a3 a4 p1 p2] } {
	set host "$a1.$a2.$a3.$a4"
	set port "[expr {$p1 * 256 + $p2}]"
    } else {
	error "Can't parse response for PASV connection port"
    }
    set sock [ns_sockopen -timeout $timeout $host $port]
    set read [lindex $sock 0]
    set write [lindex $sock 1]
    return [list $read $write]
}

proc qc::ftp_puts {ctrl_read ctrl_write string path} {
    set timeout 60
    try {
	lassign [qc::ftp_pasv $ctrl_read $ctrl_write] read write
	qc::ftp_ctrl_write $ctrl_write "STOR $path" $timeout
	if {[lindex [ns_sockselect -timeout $timeout {} $write {}] 1] == ""} {
	    error "Timeout writing to PASV port"
	}
	puts -nonewline $write $string
	flush $write
	close $write
	close $read
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	close $read
	close $write
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_puts_file {ctrl_read ctrl_write filename path {type A} } {
    set timeout 30
    try {
	set fhandle [open $filename r]
	if { [eq $type I] } {
	    fconfigure $fhandle -buffering line -translation binary -blocking 1
	    qc::ftp_type $ctrl_read $ctrl_write I
	} else {
	      qc::ftp_type $ctrl_read $ctrl_write A
	}

	lassign [qc::ftp_pasv $ctrl_read $ctrl_write] read write
	qc::ftp_ctrl_write $ctrl_write "STOR $path" $timeout
	if {[lindex [ns_sockselect -timeout $timeout {} $write {}] 1] == ""} {
	    error "Timeout writing to PASV port"
	}

	puts -nonewline $write [read $fhandle]
	close $fhandle
	flush $write
	close $write
	close $read
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	close $fhandle
	close $read
	close $write
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_rename {ctrl_read ctrl_write from to} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "RNFR $from" $timeout
	qc::ftp_ctrl_read $ctrl_read 3 $timeout
	qc::ftp_ctrl_write $ctrl_write "RNTO $to" $timeout
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_delete {ctrl_read ctrl_write path} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "DELE $path" $timeout
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_type {ctrl_read ctrl_write type} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "TYPE $type" $timeout
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_cwd {ctrl_read ctrl_write dir} {
    set timeout 30
    try {
	qc::ftp_ctrl_write $ctrl_write "CWD $dir" $timeout
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
    } {
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_list {ctrl_read ctrl_write path} {
    set timeout 60
    try {
	lassign [qc::ftp_pasv $ctrl_read $ctrl_write] read write
	qc::ftp_ctrl_write $ctrl_write "LIST $path" $timeout
	if {[lindex [ns_sockselect -timeout $timeout {} $write {}] 1] == ""} {
	    error "Timeout writing to PASV port"
	}
	set data [read $read]
	close $write
	close $read
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
	return $data
    } {
	close $read
	close $write
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_fetch {ctrl_read ctrl_write path} {
    set timeout 60
    try {
	lassign [qc::ftp_pasv $ctrl_read $ctrl_write] read write
	qc::ftp_ctrl_write $ctrl_write "RETR $path" $timeout
	if {[lindex [ns_sockselect -timeout $timeout {} $write {}] 1] == ""} {
	    error "Timeout writing to PASV port"
	}
	set data [read $read]
	close $write
	close $read
	qc::ftp_ctrl_read $ctrl_read 2 $timeout
	return $data
    } {
	close $read
	close $write
	qc::ftp_close $ctrl_read $ctrl_write
        global errorMessage errorInfo errorCode
        error $errorMessage $errorInfo $errorCode
    }
}

proc qc::ftp_ctrl_write {ctrl_write string timeout} {
    if {[lindex [ns_sockselect -timeout $timeout {} $ctrl_write {}] 1] == ""} {
        error "Timeout writing to FTP host"
    }
    puts $ctrl_write $string\r
    flush $ctrl_write
}

proc qc::ftp_ctrl_read {ctrl_read check timeout} {
    set count 0
    while {[ns_sockcheck $ctrl_read]} {
        if {[lindex [ns_sockselect -timeout $timeout $ctrl_read {} {}] 0] == ""} {
            error "Timeout reading from FTP host"
        }
        set line [gets $ctrl_read]
	#log Notice "FTP Read: $line"
	if { [regexp {^[0-9]{3} } $line code] } {
	    set short_code [string range $code 0 0]
	    if { $short_code == 1 } {
		continue
	    }
	    if { $short_code == $check } {
		return $line
	    }
            error "Expected a $check code but got:\n$line"
	}
	incr count
	if { $count > 100 } {
	    error "Iteration count exceeded for FTP read"
	}
    }
}

proc qc::ftp_get {args} {
    # usage ftp_get ?-timeout timeout? ?-userpwd user:password? url
    args $args -timeout 60 -userpwd * url
    #
    set curlHandle [curl::init]
    $curlHandle configure -url $url -ftpuseepsv 0 -userpwd $userpwd -timeout $timeout -bodyvar html
    catch { $curlHandle perform } curlErrorNumber
    set responsecode [$curlHandle getinfo responsecode]
    $curlHandle cleanup
    switch $responsecode {
	226 { 
	    # OK 
	}
	default {return -code error "RESPONSE $responsecode while contacting $url"}
    }
    switch $curlErrorNumber {
	0 {
	    # OK
	    return $html
	}
	28 {
	    return -code error -errorcode TIMEOUT "Timeout after $timeout seconds trying to contact $url"
	}
	default {
	    return -code error [curl::easystrerror $curlErrorNumber]
	}
    }
}
