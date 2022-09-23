namespace eval qc {
    namespace export ssh scp ssh_call_proc
}

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
    set filename_local  [qc::file_temp $script]
    set filename_remote "/tmp/tmp-[qc::uuid]"
    ::try {
	scp $filename_local ${username}@${host}:$filename_remote
	set out [ssh ${username}@${host} /usr/bin/tclsh $filename_remote]
	ssh ${username}@${host} rm $filename_remote
    } on error {} {
	ssh ${username}@${host} rm -f $filename_remote
    }
    file delete $filename_local
    return $out
}
