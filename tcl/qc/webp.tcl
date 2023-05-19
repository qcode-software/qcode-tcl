namespace eval qc {
    namespace export webpsize
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
