namespace eval qc {
    namespace export user_agent_parse
}

proc qc::user_agent_parse { user_agent } {
    #| Parse a user agent to a dict of device, os, and browser
    # Example:
    #     % set user_agent {Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9}
    #     % return [user_agent_parse $user_agent]
    #     device PC os MacOS browser Safari
    
    set user_agent [lower $user_agent]

    # Device
    set device "Unknown"
    if { [regexp {\y(windows nt|macintosh|linux|cros)\y} $user_agent] } {
        set device "PC"
    }

    if { [regexp {windows} $user_agent] &&
         [regexp {phone} $user_agent] } {
        set device "Mobile"
    } elseif { [regexp {android} $user_agent] &&
                [regexp {mobile} $user_agent] } {
        set device "Mobile"
    } elseif { [regexp {ip(hone|od)} $user_agent] } {
        set device "Mobile"
    }

    if { [regexp {windows} $user_agent] &&
         [regexp {touch} $user_agent] &&
         [regexp {tablet pc} $user_agent] } {
        set device "Tablet"
    } elseif { [regexp {android} $user_agent] &&
               [regexp {mobile} $user_agent] } {
        set device "Tablet"
    } elseif { [regexp {ipad} $user_agent] } {
        set device "Tablet"
    }

    # OS
    set os "Unknown"
    if { [regexp {windows nt} $user_agent] } {
        set os "Windows"
    }
    if { [regexp {macintosh} $user_agent] } {
        set os "MacOS"
    }
    if { [regexp {\ycros\y} $user_agent] } {
        set os "ChromeOS"
    }
    if { [regexp {linux} $user_agent] } {
        set os "Linux"
    }
    if { [regexp {android} $user_agent] } {
        set os "Android"
    }
    if { [regexp {windows phone} $user_agent] } {
        set os "Windows Phone"
    }
    if { [regexp {ip(hone|ad|od)} $user_agent] } {
        set os "iOS"
    }

    # Browser
    set browser "Unknown"
    if { [regexp {trident/7} $user_agent] } {
        set browser "Internet Explorer"
    }
    
    if { [regexp {safari} $user_agent] &&
         ! [regexp {(opr|chrome|presto)} $user_agent] } {
        set browser "Safari"
    }
    
    if { [regexp {chrome} $user_agent] &&
         ! [regexp {(edge|opr)} $user_agent] } {
        set browser "Chrome"
    } elseif { [regexp {crios} $user_agent] } {
        set browser "Chrome"
    }
    
    if { [regexp {(firefox|fxios)} $user_agent] } {
        set browser "Firefox"
    }
    
    if { [regexp {edg} $user_agent] } {
        set browser "Microsoft Edge"
    }

    return [dict create \
                device $device \
                os $os \
                browser $browser \
               ]
}
