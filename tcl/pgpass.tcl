namespace eval qc {
    namespace export pgpass*
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

proc qc::pgpass_credentials_exist {pgpass_filename db_name} {
    #| Check if credentials for this db_name exist in the users ~/.pgpass file
    if { [file exists $pgpass_filename] } {
        set ldict [qc::pgpass2ldict $pgpass_filename]
        set index [qc::ldict_search ldict database $db_name]
        if { $index >= 0 } {
            return true
        } 
    }
    return false
}
proc qc::pgpass_credentials {pgpass_filename db_name} {
    #| Return the access credentials for this database in the pgpass file.
    set ldict [qc::pgpass2ldict $pgpass_filename]
    set index [qc::ldict_search ldict database $db_name]
    return [lindex $ldict $index]
}   
