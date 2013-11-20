package provide qcode 2.01
package require doc
namespace eval qc {
    namespace export csv2list csv2ll
}

proc qc::csv2list {csv} {
    return [lindex [qc::csv2ll $csv] 0]
}

proc qc::csv2ll {csv } {
    #| Convert csv data to a list of lists
    #| Accepts csv quoted fields separated by commas with records terminated by newlines.
    #| Commas and newlines may appear inside a quoted field.
    # Windows -> UNIX
    regsub -all {\r\n} $csv \n csv
    
    # Optimized for csv with no quotes
    if {[string first \" $csv]==-1} {
	# trim whitespace around fields
	regsub -all {(^|\n|,) +} $csv {\1} csv
	regsub -all { +($|\n|,)} $csv {\1} csv
	set result {}
	foreach line [split $csv \n] {
	    lappend result [split $line ,]
	}
	return $result
    }
    # Escape commas embedded in quoted fields with \0
    # Escape newlines embedded in quoted fields with \1
    # Escape double quotes embedded in quoted fields with \2
    # regsub -all won't work because the regexp need to be applied repeatedly to anchor correctly
    set start 0
    while { $start<[string length $csv] && \
		[regexp -expanded -indices -start $start -- {
		    (?:^|\n|,)\s*
		    \"
		    (
		     ([^\"]|\"\")*
		     (,|\n|"")
		     ([^\"]|\"\")*
		     )
		    \"
		    \s*(?:,|\n|$)
		} $csv -> field] } {
	set field_value [string range $csv [lindex $field 0] [lindex $field 1]]
	set escaped_value [string map [list , \0 \n \1 \"\" \2] $field_value]
	set csv [string replace $csv [lindex $field 0] [lindex $field 1] $escaped_value]
	set start [expr {[lindex $field 0]+[string length $escaped_value]+1}]
    }

    set csv [string map {, \0 \0 ,} $csv] 
    # trim whitespace
    regsub -all {(^|\n|\0) +} $csv {\1} csv
    regsub -all { +($|\n|\0)} $csv {\1} csv
    # remove quotes - no longer needed
    set csv [string map {\" {}} $csv] 

    set result {}
    foreach line [split $csv \n] {
	lappend result [split [string map {\1 \n \2 \"} $line] \0]
    }
    return $result
}

doc qc::csv2ll {
    Examples {
	% set csv {"one","two","three"
4,5,6}
	% csv2ll $csv
	{one two three} {4 5 6}
	%
	set csv {,"one
two","three"",",",""four",","
2,3,4,",
",9}
	% csv2ll $csv
	{{} {one
two} three\", ,\"four ,} {2 3 4 {,
} 9}
    }
}

