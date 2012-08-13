package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::my {args} {
    switch [lindex $args 0] {
	hostname {
	    return [::exec hostname -s]
	}
	fqdn {
	    return [::exec hostname -f]
	}
	domain {
	    return [::exec hostname -d]
	}
        ip {
	    regexp {inet ([^/]*)/} [::exec ip addr show scope global | fgrep inet] -> ip
	    return $ip
        }
        username {
            global env
            # Attempts to return the original username by looking in SUDO_USER, then defaulting to whoami if empty
            if { ![info exists env(SUDO_USER)] } {
                return [::exec whoami]
            } else {
                return $env(SUDO_USER)
            }
        }
        arch {
            switch [::exec getconf LONG_BIT] {
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
            # EC2 only
            return [qc::http_get http://169.254.169.254/latest/meta-data/instance-id]
        }
    }
}
