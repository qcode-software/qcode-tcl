proc qc::my {args} {
    #| Multifunction proc to return information about the local OS.
    #| Written to be debian specific but may work on some other Linux distributions.
    switch [lindex $args 0] {
	hostname {
	    return [qc::exec_proxy hostname -s]
	}
	fqdn {
	    return [qc::exec_proxy hostname -f]
	}
	domain {
	    return [qc::exec_proxy hostname -d]
	}
        ip {
	    regexp {inet ([^/]*)/} [qc::exec_proxy ip addr show scope global | fgrep inet] -> ip
	    return $ip
        }
        arch {
            switch [qc::exec_proxy getconf LONG_BIT] {
                64 { return "amd64" }
                32 { return "i386" }
            }
        }
        total_memory {
            #| Returned in kB
            set fp [open /proc/meminfo]
            set meminfo [read $fp]
            close $fp
            
            regexp -all -linestop -lineanchor -- {^\s*MemTotal:\s+([^[:space:]]+) ([^[:space:]]+)$} $meminfo -> total_mem units
            return $total_mem
        }
        instance_id {
            # AWS only
            return [qc::aws_metadata instance-id]
        }
        availability_zone {
            # AWS only
            return [qc::aws_metadata placement/availability-zone]
        }
    }
}

