proc qc::sftp_put {args} {
    args $args -port 22 username password host filename data
    if { [regexp {^/} $filename] } {
	set url sftp://${host}:${port}${filename}
    } else {
	set url sftp://${host}:${port}/~/${filename}
    }
    if { ![nsv_exists which curl] } {
	nsv_set which curl [exec which curl]
    }
    
    set file [open "|[nsv_get which curl] -k -T - -u $username:$password $url" w]
    puts -nonewline $file $data
    close $file
}