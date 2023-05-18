proc qc::is::webp {file} {
    #| Check if the file is a webp image.
    set fin [open $file rb]
    set chunk0 [read $fin 12]
    close $fin

    binary scan $chunk0 "a4ia4" riff size id

    return [expr {
                  [info exists riff]
                  && [info exists id]
                  && $riff eq "RIFF"
                  && $id eq "WEBP"
              }]
}
