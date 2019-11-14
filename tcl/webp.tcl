namespace eval qc {
}

proc qc::is_webp {file} {
    set fin [open $file rb]
    set chunk0 [read $fin 12]
    set chunk1 [read $fin 28]
    close $fin

    binary scan $chunk0 "a4ia4" riff size id

    return [expr {$riff eq "RIFF" && $id eq "WEBP"}]
}

proc qc::webpsize {file} {
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
