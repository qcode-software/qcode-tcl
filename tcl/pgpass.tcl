namespace eval qc {
    namespace export pgpass2ldict
}


proc qc::pgpass2ldict {filename} {
    #| Convert the contents of the current user's .pgpass as an ldict
    set ldict [list]
    set lines [split [qc::cat $filename] \n]
    foreach line $lines {
        if { [regexp {^ *#} $line] } {
            continue
        }
        if { [regexp {^([^:]+):([^:]+):([^:]+):([^:]+):(.+)$} $line -> hostname port database username password] } {
            lappend ldict [dict_from hostname port database username password]
        }
    }
    return $ldict
}
