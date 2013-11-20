package provide qcode 2.02
package require doc
namespace eval qc {
    namespace export socket_*
}

proc qc::socket_open {host port timeout} {
    #| Open a TCP socket with timeout

    set sock [socket -async $host $port]
    # Store socket state in global array
    global sock_state

    # After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,write) "timeout"]]

    # Asynchronous. When $sock becomes writable, set sock_state($sock,write).
    fileevent $sock writable [list set sock_state($sock,write) "writable"]
   
    # Wait for socket state to change
    vwait sock_state($sock,write)

    # Cleanup.
    after cancel $id
    set state $sock_state($sock,write)
    unset sock_state($sock,write)

    # Check if the socket timed-out
    if { $state eq "timeout" } {
        error "Timeout waiting to connect to $host on port $port"
    }

    # Check for socket error
    # fconfigure $sock -error gets and clears any error states so call once only.
    set sock_error [fconfigure $sock -error]
    if { $sock_error ne "" } {
        error "Socket connection error: $sock_error"
    }

    # Config
    fconfigure $sock -blocking 0 -buffering line
    return $sock
}

proc qc::socket_puts {args} {
    #| Write data to a tcp socket with timeout
    args $args -nonewline -- sock string timeout

    # Store socket state in global array
    global sock_state

    # After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,write) "timeout"]]

    # Asynchronous. When $sock becomes writable, set sock_state($sock,write).
    fileevent $sock writable [list set sock_state($sock,write) "writable"]

    # Wait for socket state to change
    vwait sock_state($sock,write)

    # Cleanup. 
    after cancel $id
    set state $sock_state($sock,write)
    unset sock_state($sock,write)

    # Check if the socket timed-out
    if { $state eq "timeout" } {
        error "Timeout waiting to write to socket"
    }
    
    # Check for socket error
    # fconfigure $sock -error gets and clears any error states so call once only.
    set sock_error [fconfigure $sock -error]
    if { $sock_error ne "" } {
        error "Socket error: $sock_error"
    }

    # At this point $sock should be writable - go ahead with puts
    if { [info exists nonewline] } {
	puts -nonewline $sock $string
    } else {
	puts $sock $string
    }
}

proc qc::socket_gets {sock timeout} {
    #| Read data from a tcp socket with timeout

    # Store socket state in global array
    global sock_state sock_data

    # Check Config
    fconfigure $sock -blocking 0 -buffering line

    # After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,read) timeout]]

    # When $sock becomes readable
    fileevent $sock readable [list qc::socket_gets_if_ready $sock]

    # Wait for socket state to change
    vwait sock_state($sock,read)

    # Cleanup.
    after cancel $id
    set state $sock_state($sock,read)
    unset sock_state($sock,read)
    
    # Check if the socket timed-out
    if { $state eq "timeout" } {
	error "Timeout waiting to read from socket"
    }

    # Check for socket error
    # fconfigure $sock -error gets and clears any error states so call once only.
    set sock_error [fconfigure $sock -error]
    if { $sock_error ne "" } {
	error "Socket error: $sock_error"
    }

    # Cleanup
    set data $sock_data($sock)
    unset sock_data($sock)

    return $data
}

proc qc::socket_gets_if_ready { sock } {
    #| Called when a socket is readable
    # Event and data passed back through global variables
    global sock_state sock_data
    gets $sock line
    if { [eof $sock] } {
        set sock_data($sock) ""
        set sock_state($sock,read) "eof"
    } elseif { ![fblocked $sock] } {
        set sock_data($sock) $line
        set sock_state($sock,read) "done"
    } 
}

