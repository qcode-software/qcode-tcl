namespace eval qc {
}

proc qc::is_webp {file} {
    #| Test whether a given file is a webp image
    set fin [open $file rb]
    set chunk0 [read $fin 12]
    close $fin

    binary scan $chunk0 "a4ia4" riff size id

    if { [info exists riff] && [info exists id] } {
        return [expr {$riff eq "RIFF" && $id eq "WEBP"}]
    } else {
        return 0
    }
}

proc qc::is_webp_old {file} {
    #| Test whether a given file is a webp image
    set fin [open $file rb]
    set chunk0 [read $fin 12]
    set chunk1 [read $fin 28]
    close $fin

    binary scan $chunk0 "a4ia4" riff size id

    return [expr {$riff eq "RIFF" && $id eq "WEBP"}]
}

proc qc::webpsize {file} {
    #| Get the width and height of a webp image file
    set info [exec_proxy \
                  -timeout 1000 \
                  -ignorestderr \
                  identify \
                  $file]
    lassign [split $info " "] {*}{
        filename
        format
        dimensions
        page_dimensions
        colorspace
        usertime
        elaspedtime
    }
    return [split $dimensions "x"]
}
