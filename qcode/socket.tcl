package provide qcode 1.4
package require doc
namespace eval qc {}

proc qc::socket_puts {args} {
    #| Write data to a tcp socket with timeout
    args $args -nonewline -- sock string timeout

    # Store socket state in global array
    global sock_state

    # Asynchronous. When $sock becomes writable, set state_${sock}_write.
    fileevent $sock writable [list set sock_state($sock,write) "writable"]

    # Asynchronous. After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,write) "timeout"]]

    # Wait for socket state to change
    vwait sock_state($sock,write)

    # Cleanup. Cancel the timeout timer (it may already have expired)
    after cancel $id

    # Check if the socket timed-out
    set state $sock_state($sock,write)
    # tidy up
    unset sock_state($sock,write)
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

    # Asynchronous. When $sock becomes readable, set sock_state($sock,read).
    fileevent $sock readable [list set sock_state($sock,read) "readable"]

    # Asynchronous. After $timeout seconds flag socket state as timeout.
    set id [after [expr {$timeout*1000}] [list set sock_state($sock,read) "timeout"]]

    # Wait for socket state to change
    vwait sock_state($sock,read)

    # TODO This works well if $timeout is less than 20 seconds. 
    # Above this and there seems to be a system default timeout (perhaps in the TCP stack) which
    # trips and makes the socket go into an error state and, for some reason, become "readable". 
    # So we must check fconfigue $sock -error also to be sure of the state.
    # The bottom line is that the $timeout value is ignored above 20

    # Cleanup. Cancel the timeout timer (it may already have expired)
    after cancel $id

    # Check if the socket timed-out
    set state $sock_state($sock,read)
    # tidy up
    unset sock_state($sock,read)
    if { $state eq "timeout" } {
	error "Timeout waiting to read from socket"
    }
    # Check for socket error
    # fconfigure $sock -error gets and clears any error states so call once only.
    set sock_error [fconfigure $sock -error]
    if { $sock_error ne "" } {
	error "Socket error: $sock_error"
    }

    # At this point $sock should be readable - go ahead with gets
    return [gets $sock]
}
