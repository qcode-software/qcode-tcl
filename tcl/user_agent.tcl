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
    
    if { [regexp {\ywindows\y} $user_agent] &&
         [regexp {\ytouch\y} $user_agent] &&
         ! [regexp {\ytablet pc\y} $user_agent] } {
        set device "Tablet"
    } elseif { [regexp {\yandroid\y} $user_agent] &&
               ! [regexp {\ymobile\y} $user_agent] } {
        set device "Tablet"
    } elseif { [regexp {\yipad\y} $user_agent] } {
        set device "Tablet"
    }

    if { [regexp {\ywindows\y} $user_agent] &&
         [regexp {\yphone\y} $user_agent] } {
        set device "Mobile"
    } elseif { [regexp {\yandroid\y} $user_agent] &&
                [regexp {\ymobile\y} $user_agent] } {
        set device "Mobile"
    } elseif { [regexp {\yip(hone|od)\y} $user_agent] } {
        set device "Mobile"
    }

    # OS
    set os "Unknown"
    if { [regexp {\ywindows nt\y} $user_agent] } {
        set os "Windows"
    }
    if { [regexp {\ymacintosh\y} $user_agent] } {
        set os "macOS"
    }
    if { [regexp {\ycros\y} $user_agent] } {
        set os "ChromeOS"
    }
    if { [regexp {\ylinux\y} $user_agent] } {
        set os "Linux"
    }
    if { [regexp {\yandroid\y} $user_agent] } {
        set os "Android"
    }
    if { [regexp {\ywindows phone\y} $user_agent] } {
        set os "Windows Phone"
    }
    if { [regexp {\yip(hone|ad|od)\y} $user_agent] } {
        set os "iOS"
    }

    # Browser
    set browser "Unknown"
    if { [regexp {\ytrident/7\y} $user_agent] } {
        set browser "Internet Explorer"
    }
    
    if { [regexp {\ysafari\y} $user_agent] &&
         ! [regexp {(opr|chrome|presto)} $user_agent] } {
        set browser "Safari"
    }
    
    if { [regexp {\ychrome\y} $user_agent] &&
         ! [regexp {\y(edge|opr)\y} $user_agent] } {
        set browser "Chrome"
    } elseif { [regexp {\ycrios\y} $user_agent] } {
        set browser "Chrome"
    }
    
    if { [regexp {\y(firefox|fxios)\y} $user_agent] } {
        set browser "Firefox"
    }
    
    if { [regexp {\yedge?\y} $user_agent] } {
        set browser "Microsoft Edge"
    }

    return [dict create \
                device $device \
                os $os \
                browser $browser \
               ]
}
