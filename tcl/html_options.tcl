namespace eval qc {
    namespace export html_options_*
}

proc qc::html_options_db { qry } {
    #| Expects a qry use columns named "name" and "value"
    #| Use aliases where required.
    #| E.g select foo_id as value,description as name from foo
    set options {}
    db_cache_foreach $qry {
	lappend options $name $value
    }
    return $options
}

proc qc::html_options_db_cache { qry {ttl 86400}} {
    #| Expects a qry use columns named "name" and "value"
    #| Use aliases where required.
    #| E.g select foo_id as value,description as name from foo
    #| Query results are cached 
    set options {}
    db_cache_foreach -ttl $ttl $qry {
	lappend options $name $value
    }
    return $options
}

proc qc::html_options_simple { args } {
    #| Use list items as both name and value
    #| Eg Converts one two three -> one one two two three three
    set options {}
    foreach item $args {
        lappend options $item $item
    }
    return $options
}

