package provide qcode 2.03.0
package require doc
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

doc qc::html_options_db {
    Examples {
	% set qry {select country as name,country_code as value from countries order by country}
	% qc::html_options_db $qry
	Afghanistan AF Albania AL Algeria DZ ..... Yemen YE Yugoslavia YU Zambia ZM Zimbabwe ZW
    }
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

doc qc::html_options_db_cache {
    Examples {
	% set qry {select country as name,country_code as value from countries order by country}
	% qc::html_options_db_cache $qry
	Afghanistan AF Albania AL Algeria DZ ..... Yemen YE Yugoslavia YU Zambia ZM Zimbabwe ZW
    }
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

doc qc::html_options_simple {
    Examples {
	% qc::html_options_simple red orange blue green
	red red orange orange blue blue green green
    }
}



