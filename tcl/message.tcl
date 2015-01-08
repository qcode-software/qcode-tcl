namespace eval qc::message {

    namespace export notify alert warning error
    namespace ensemble create

    proc notify {message} {
        #| Sets the notify property with the given message.
        global data
        dict set data message notify value $message
    }

    proc alert {message} {
        #| Sets the notify property with the given message.
        global data
        dict set data message alert value $message
    }

    proc error {message} {
        #| Sets the notify property with the given message.
        global data
        dict set data message error value $message
    }

    proc warning {message} {
        #| Sets the notify property with the given message.
        global data
        dict set data message warning value $message
    }
}