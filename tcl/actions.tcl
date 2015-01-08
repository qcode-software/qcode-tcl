namespace eval qc::actions {

    namespace export redirect login
    namespace ensemble create

    proc redirect {url} {
        #| Sets the redirect property with the given URL.
        global data
        reset
        dict set data action redirect value [url $url]
    }

    proc login {url} {
        #| Sets the login property with the given URL.
        global data
        reset
        dict set data action login value [url $url]
    }

    proc reset {} {
        #| Resets the action property of the data structure.
        global data
        if {[info exists data] && [dict exists $data action]} {
            dict unset data action
        }
    }
}