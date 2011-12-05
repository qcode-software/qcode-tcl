package provide qcode 1.2
package require doc
namespace eval qc {}
proc qc::sftp_put {args} {
    args $args -port 22 username password host filename data
    if { [regexp {^/} $filename] } {
	set url sftp://${host}:${port}${filename}
    } else {
	set url sftp://${host}:${port}/~/${filename}
    }
    if { ![nsv_exists which curl] } {
	nsv_set which curl [exec_proxy which curl]
    }
    
    set file [open "|[nsv_get which curl] -k -T - -u $username:$password $url 2>/dev/null" w]
    puts -nonewline $file $data
    close $file
}