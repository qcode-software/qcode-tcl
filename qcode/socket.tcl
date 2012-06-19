package provide qcode 1.5
package require doc
namespace eval qc {}

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
    global sock_state

    # After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,read) "timeout"]]

    # When $sock becomes readable, set sock_state($sock,read).
    fileevent $sock readable [list set sock_state($sock,read) "readable"]

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

    # Check Config
    fconfigure $sock -blocking 0 -buffering line

    # Socket is now readable but could stutter one byte at a time
    # Loop until sufficent data to read or timeout
    # gets returns -1 if insufficient data to read.
    set step 100
    set timer 0
    while {$timer <= $timeout*1000 && [gets $sock line]==-1 } {
	after $step
	incr timer $step
    }

    if {$timer>$timeout*1000} {
	# raise error
	error "Timeout waiting to read from socket"
    }

    return $line
}