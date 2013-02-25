package provide qcode 1.16
package require doc
namespace eval qc {}

proc qc::perl_quote {value} {
    #| Quote a value for use as a perl scalar
    return \"[string map [list \" \\\"] $value]\"
}

proc qc::list2perl_array {list} {
    #| Convert a list into a perl array
    set quoted_values {}
    foreach value $list {
        lappend quoted_values [perl_quote $value]
    }
    return \[[join $quoted_values ", "]\]
}

proc qc::dict2perl_hash {dict} {
    #| Convert a dict into a perl hash
    set pairs {}
    dict for {name value} $dict {
        lappend pairs "$name => [perl_quote $value]"
    }
    return \{[join $pairs ", "]\}
}

proc qc::llist2perl_aarray {llist} {
    #| Convert a list of lists into a perl array of arrays
    set array_list {}
    foreach list $llist {
        lappend array_list [list2perl_array $list]
    }
    return \[[join $array_list ", "]\]
}

proc qc::ddict2perl_hhash {ddict} {
    #| Convert a nested dict into a perl hash of hashes
    set pairs {}
    dict for {key dict} $ddict {
        lappend pairs "$key => [dict2perl_hash $dict]"
    }
    return \{[join $pairs ", "]\}
}