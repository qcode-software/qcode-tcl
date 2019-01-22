namespace eval qc {
    namespace export tabular_text_parse
}

proc qc::tabular_text_parse  {args} {
    #| Parse text tabular data and return TCL table data structure
    # Example:
    #     % set lines {}
    #     % lappend lines "Column 1 Column 2"
    #     % lappend lines "a        b      "
    #     % set text [join $lines \n]
    #
    #     % set conf {}
    #     % lappend conf [list label "Column 1" var_name "col1"]
    #     % lappend conf [list label "Column 2" var_name "col2"]
    #
    #     % return [tabular_text_parse $text $conf]
    #     {{col1 col2} {a b}}
    qc::args $args -ignore_empty_rows -- text columns_conf
    
    # convert text to list of lines of required min width (determined by line for table header)
    set temp {}
    foreach line [split [string map {\r ""} $text] \n] {
        lappend temp $line
    }
    # check table header line contains all column_headings and replace whitespace in headings with underscores
    set table_header_line [lindex $temp 0]
    foreach conf $columns_conf {
        dict2vars $conf label
        # replace whitespace with underscore to prevent column headers being split into multiple columns later on
        set new_label [regsub -all {\s} $label "_"]
        if { ! [regsub "(^|\\s)[regexp_escape $label](\\s|$)" $table_header_line "\\1$new_label\\2" table_header_line] } {
            error "Unable to locate column heading \"$label\""
        }
    }
    set lines [list $table_header_line]
    # padd all other lines with spaces to have at least same number of characters as the header
    set min_width [string length $table_header_line]    
    foreach line [lrange $temp 1 end] {
        if { [string length $line] < $min_width } {
            lappend lines [qc::format_left $line $min_width]
        } else {
            lappend lines $line
        }
    }
  
    # Generate list of indices for vertical columns of whitespace characters
    set vertical_whitespaces {}
    set i 0 
    foreach line $lines {
        incr i
        
        if { $i == 1 } {
            # first line - get indices of all whitespace characters
            set vertical_whitespaces [regexp -all -inline -indices {\s} $line]                 
        } else {
            # remaining lines - perform intersect to find indices for vertical columns of whitespace characters
            set vertical_whitespaces [qc::lintersect $vertical_whitespaces [regexp -all -inline -indices {\s} $line]]
        }
    }
    
    # conbine consecutive vertical whitespace indices 
    set column_separators {}
    set i 0
    set group_start 0
    set group_end 0
    foreach vertical_whitespace $vertical_whitespaces {
        incr i
        lassign $vertical_whitespace start end
        
        if { $i == 1 } {
            # first vertical whitespace - start new group
            set group_start $start
            set group_end $end
        }
        
        if { $i == [llength $vertical_whitespaces] } {
            # last vertical whitespace - close current group then add as column separator
            set group_end $end
            lappend column_separators [list $group_start $group_end]
        } elseif { $start - $group_end > 1 } {
            # non-consequetive vertical whitespace - add column separator and start new group
            lappend column_separators [list $group_start $group_end]
            set group_start $start
            set group_end $end
        } else {
            # consecutive vertical  whitespace - extend current group
            set group_end $end
        }
    }
    
    # ignore column separators before first and after last table headings
    set result [regexp -inline -indices {^\s*\S} $table_header_line]
    set first_heading_start [lindex $result 0 1]
    set result [regexp -inline -indices {\S\s*$} $table_header_line]
    set last_heading_end [lindex $result 0 0]
    foreach column_separator $column_separators {
        lassign $column_separator column_separator_start column_separator_end
        if { $column_separator_end <= $first_heading_start || $column_separator_start >= $last_heading_end } {
            # discard column separators
            set column_separators [lexclude $column_separators $column_separator]
        }
    }
    # ignore multiple column separators between table headings (just keep the last one)
    set result [regexp -all -inline -indices {\s+} $table_header_line]
    foreach header_whitespace $result {
        lassign $header_whitespace header_whitespace_start header_whitespace_end
        set i 0 
        foreach column_separator [lreverse $column_separators] {
            lassign $column_separator column_separator_start column_separator_end
            if { $column_separator_start >= $header_whitespace_start && $column_separator_end <= $header_whitespace_end && $i == 0 } {
                # keep last column separator
                incr i
            } elseif { $column_separator_start >= $header_whitespace_start && $column_separator_end <= $header_whitespace_end } {
                # discard other column separators
                set column_separators [lexclude $column_separators $column_separator]
            }
        }
    }
    
    # generate TCL table data structure
    set table {}
    set i 0
    foreach line $lines {
        incr i
        if { [info exists ignore_empty_rows] && [trim $line] eq "" } {
            # ignore blank rows
            continue
        }
        
        # split lines on column separators and trim whitespace from values
        foreach separator [lreverse $column_separators] {
            lassign $separator start end
            set line [string replace $line $start $end \0]
        }
        if { $i == 1 } {
            # table heading line - replace headings with desired variable names 
            foreach conf $columns_conf {
                dict2vars $conf label var_name
                set new_label [regsub -all {\s} $label "_"]
                if { ! [regsub "(^|\\0|\\s)[regexp_escape $new_label](\\0|\\s|$)" $line "\\1${var_name}\\2" line] } {
                    error "Unable to locate column heading \"$label\""
                }
            }
        } 
        set row {}
        foreach value [split $line \0] {
            lappend row [trim $value]
        }
        
        # raise error if we have too many/little columns
        if { [llength $row] != [llength $columns_conf] } {
            error "Found [llength $row] columns, expected [llength $columns_conf] for line \"$line\""
        }
        
        lappend table $row
    }
    return $table
}
