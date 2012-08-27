package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::ssh {args} {
    #| Execute an ssh command with some default options 
    set args [linsert $args 0 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q]
    return [exec -ignorestderr ssh {*}$args]
}

proc qc::scp {args} {
    #| Execute an scp command with some default options 
    set args [linsert $args 0 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q]
    return [exec -ignorestderr scp {*}$args]
}

proc qc::ssh_call_proc {args} {
    #| Take a proc definition and args and write a Tcl script that can be run on the remote host
    # eg. ssh_call_proc user@remote link_checker /var/www/www.example.com
 
    if {![regexp {^([^@]+)@([^@]+)$} [lindex $args 0] -> username host] } {
	error "Usage ssh_call_proc user@host proc_name args"
    }
    qc::lshift args
    set proc_name [qc::lshift args]
    set script [qc::info_proc $proc_name]
    append script \n "puts \[$proc_name $args\]"
    set filename [qc::file_temp $script]
    try {
	scp $filename ${username}@${host}:$filename
	set out [ssh ${username}@${host} /usr/bin/tclsh8.5 $filename]
	ssh ${username}@${host} rm $filename    
    } {
	ssh ${username}@${host} rm -f $filename    
    }
    file delete $filename
    return $out
}
