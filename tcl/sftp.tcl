package provide qcode 2.03
package require doc
namespace eval qc {
    namespace export sftp_put
}

proc qc::sftp_put {args} {
    #| Write data to the filename on the remote host using sftp
    args $args -port 22 username password host filename data
    if { [regexp {^/} $filename] } {
	set url sftp://${host}:${port}${filename}
    } else {
	set url sftp://${host}:${port}/~/${filename}
    }
    
    set file [open "|[qc::which curl] -k -T - -u $username:$password $url 2>/dev/null" w]
    puts -nonewline $file $data
    close $file
}


