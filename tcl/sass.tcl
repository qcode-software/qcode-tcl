namespace eval qc {
}

proc qc::sass_recompile {src dest} {
    #| Recompiles sass files if they have changed.
    set reload false
    set sass [exec which sass]
    set files [glob -nocomplain $src/*.scss $src/*/*.scss]
    array set md5s {}
    
    if { [info commands nsv_exists] ne "" } {
        # Running in Naviserver. Check if there been any changes before recomiling sass.
        foreach file $files {
            set fh [open $file r]
            set md5 [qc::md5 [read $fh]]
            close $fh
            
            if { !([nsv_exists sass_file_md5 $file] && ($md5 eq [nsv_get sass_file_md5 $file])) } {
                log Notice "Compiling scss file $file"
                set reload true
            }
            # Make a note of md5 for this file
            set md5s($file) $md5
        }
    } else {
        # Not running in Naviserver. always recompile sass
        set reload true
    }
    
    if { $reload } {
        if { [catch {exec $sass -l --update --style expanded --stop-on-error $src:$dest} errorMessage options] } {
            return -code error -options $options $errorMessage
        } else {
            if { [info commands nsv_exists] ne "" } {
                # Update md5 records
                foreach file $files {
                    nsv_set sass_file_md5 $file $md5s($file)
                }
            }
        }
    }
}