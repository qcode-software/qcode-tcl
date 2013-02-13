package provide qcode 1.13
package require doc
namespace eval qc {}

proc qc::excel_file_create {args} {
    #| Creates an xls file using the information provided
    # data: a list of lists containing a grid of cell values
    # formats: a dict of class definitions
    # class definitions: a dict of name-value pairs
    # column_meta: list of dicts, eg. {{index 1 class "foo" width 20} {index 5 width 50}}
    # row_meta: list of dicts, eg. {{index 0 class "bar" height 20} {index 3 class "foo"}}
    # cell_meta: list of dicts, eg. {{row 5 column 2 class "baz" type "string|number|formula|url"} {row 1 column 1 class "bar"}}
    args2vars $args data formats column_meta row_meta cell_meta
    default data {}
    default formats {}
    default column_meta {}
    default row_meta {}
    default cell_meta {}

    set filename [file_temp ""]
    ########################################
    # Template
    ########################################
    set template {#!/usr/bin/perl -w
        use strict;
        use Spreadsheet::WriteExcel;

        ####################
        # Data
        ####################

        # Insert filename here
        my $workbook = Spreadsheet::WriteExcel->new('<filename>');
        my $worksheet = $workbook->add_worksheet();

        # Cell data, eg.
        # my @data = (
        #    ["name", "DOB", "Telephone"],
        #    ["Bob", "12/12/12", "1234 5678"],
        #    ["Jane", "01/01/01", "0123 9876"]
        # );
        my @data = (<cell_data>);

        # Workbook formats, eg.
        # my %formats = (
        #    bold => $workbook->add_format(
        #        bold => 1,
        #        color => 'green'
        #    ),
        #    red => $workbook->add_format(
        #        color => 'red'
        #    )
        # );
        my %formats = (<formats>);

        # Column meta-data, eg.
        # my %column_meta = (
        #    0 => {
        #        class => "red",
        #        width => 30
        #    }
        # );
        my %column_meta = (<column_meta>);

        # Row meta-data, eg.
        # my %row_meta = (
        #    0 => {
        #        class => "bold",
        #        height => 25
        #    }
        # );
        my %row_meta = (<row_meta>);

        # Cell meta-data, eg.
        # my %cell_meta = (
        #    2 => {
        #        1 => {
        #            class => "red",
        #            type => "string"
        #        },
        #        2 => {
        #            class => "bold"
        #        }
        #    }
        # );
        my %cell_meta = (<cell_meta>);


        ####################
        # Logic
        ####################

        # Column meta
        foreach my $i ( keys %column_meta ) {
            my $format;
            if ( exists $column_meta{$i}{"class"} ) {
                $format = $formats{$column_meta{$i}{"class"}};
            }
            my $width = $column_meta{$i}{"width"};
            $worksheet->set_column($i, $i, $width, $format);
        }

        # Row meta
        foreach my $i ( keys %row_meta ) {
            my $format;
            if ( exists $row_meta{$i}{"class"} ) {
                $format = $formats{$row_meta{$i}{"class"}};
            }
            my $height = $row_meta{$i}{"height"};
            $worksheet->set_row($i, $height, $format);
        }

        # Cells
        $worksheet->keep_leading_zeros();
        for my $i ( 0 .. $#data ) {
            for my $j ( 0 .. $#{ $data[$i] } ) {
                my $format;
                if ( exists $cell_meta{$i}{$j}{"class"} ) {
                    $format = $formats{$cell_meta{$i}{$j}{"class"}};
                }
                my $type = $cell_meta{$i}{$j}{"type"};

                if ( ! defined $type ) {
                    # Guess type based on value
                    $worksheet->write($i, $j, $data[$i][$j], $format);

                } elsif ( $type eq "string" ) {
                    $worksheet->write_string($i, $j, $data[$i][$j], $format);

                } elsif ( $type eq "number" ) {
                    $worksheet->write_number($i, $j, $data[$i][$j], $format);

                } elsif ( $type eq "formula" ) {
                    $worksheet->write_formula($i, $j, $data[$i][$j], $format);

                } elsif ( $type eq "url" ) {
                    my $url = $cell_meta{$i}{$j}{"url"};
                    $worksheet->write_url($i, $j, $url, $data[$i][$j], $format);
                }
            }
        }
    }
    # End of template


    ########################################
    # Perl Data
    ########################################

    # Cell data - A list of list becomes an array of arrays
    set cell_data {}
    foreach row $data {
        set row [string map [list \" \\\"] $row]
        lappend cell_data "\[\"[join $row {", "}]\"\]"
    }
    set cell_data "[join $cell_data ","]"

    # Formats - a dict of dicts becomes a hash of format objects added to the current workbook
    set format_list {}
    dict for {class format} $formats {
        set attribute_list {}
        dict for {attribute value} $format {
            switch $attribute {
                "font-family" {
                    lappend attribute_list "font => \"$value\""
                }
                "font-size" {
                    lappend attribute_list "size => $value"
                }
                "font-weight" {
                    if {$value eq "bold"} {
                        lappend attribute_list "bold => 1"
                    } else {
                        error "$css_attribute $css_value is unsupported"
                    }
                }
                "font-style" {
                    if {$value eq "italic"} {
                        lappend attribute_list "italic => 1"
                    } else {
                        error "$css_attribute $css_value is unsupported"
                    }
                }
                "text-decoration" {
                    switch $value {
                        "underline" {
                            lappend attribute_list "underline => 1"
                        }
                        "line-through" {
                            lappend attribute_list "font_strikeout => 1"
                        }
                        default {
                            error "$css_attribute $css_value is unsupported"
                        }
                    }
                }
                "text-align" {
                    lappend attribute_list "align => \"$value\""
                }
                "vertical-align" {
                    if {$value eq "middle"} {
                        set value "vcenter"
                    }
                    lappend attribute_list "valign => \"$value\""
                }
                "background" -
                "background-color" {
                    lappend attribute_list "bg_color => \"$value\""
                }
                "border" -
                "border-top" -
                "border-right" -
                "border-bottom" -
                "border-left" {
                    set side [string range $attribute 7 end]
                    if {$side eq ""} {
                        set side "border"
                    }
                    set values [split $value " "]
                    set color [lindex $values 2]
                    switch [lindex $values 1] {
                        "solid" {
                            switch [lindex $values 0] {
                                "1px" {
                                    set index 1
                                }
                                "2px" {
                                    set index 2
                                }
                                "3px" {
                                    set index 5
                                }
                                default {
                                    error "$css_attribute $css_value is unsupported"
                                }
                            }
                        }
                        "dashed" {
                            switch [lindex $values 0] {
                                "1px" {
                                    set index 3
                                }
                                "2px" {
                                    set index 8
                                }
                                default {
                                    error "$css_attribute $css_value is unsupported"
                                }
                            }
                        }
                        "dotted" {
                            switch [lindex $values 0] {
                                "1px" {
                                    set index 7
                                }
                                default {
                                    error "$css_attribute $css_value is unsupported"
                                }
                            }
                        }
                        "double" {
                            switch [lindex $values 0] {
                                "1px" {
                                    set index 6
                                }
                                default {
                                    error "$css_attribute $css_value is unsupported"
                                }
                            }
                        }
                        default {
                            error "$css_attribute $css_value is unsupported"
                        }
                    }
                    lappend attribute_list "$side => $index"
                    lappend attribute_list "${side}_color => \"$color\""
                }
                default {
                    set value \"[string map [list \" \\\"] $value]\"
                    lappend attribute_list "$attribute => $value"
                }
            }
        }
        lappend format_list "$class => \$workbook->add_format([join $attribute_list ","])"
    }
    set formats "[join $format_list ","]"

    # Colum meta-data - a list of dicts becomes a hash of hashes, using "index" as the hash key
    set column_list {}
    foreach column $column_meta {
        set attribute_list {}
        dict for {attribute value} [dict_exclude $column index] {
            set value \"[string map [list \" \\\"] $value]\"
            lappend attribute_list "$attribute => $value"
        }
        lappend column_list "[dict get $column index] => \{[join $attribute_list ","]\}"
    }
    set column_meta "[join $column_list ","]"

    # Row meta-data - a list of dicts becomes a hash of hashes, using "index" as the hash key
    set row_list {}
    foreach row $row_meta {
        set attribute_list {}
        dict for {attribute value} [dict_exclude $row index] {
            set value \"[string map [list \" \\\"] $value]\"
            lappend attribute_list "$attribute => $value"
        }
        lappend row_list "[dict get $row index] => \{[join $attribute_list ","]\}"
    }
    set row_meta "[join $row_list ","]"

    # Cell meta-data - a list of dicts becomes a hash of hashes of hashes, using "row" then "column" as keys
    set cell_meta_dict {}
    foreach cell $cell_meta {
        set attribute_list {}
        dict for {attribute value} [dict_exclude $cell row column] {
            set value \"[string map [list \" \\\"] $value]\"
            lappend attribute_list "$attribute => $value"
        }
        dict set cell_meta_dict [dict get $cell row] [dict get $cell column] $attribute_list
    }
    set row_list {}
    dict for {row row_data} $cell_meta_dict {
        set column_list {}
        dict for {column attribute_list} $row_data {
            lappend column_list "$column => \{[join $attribute_list ","]\}"
        }
        lappend row_list "$row => \{[join $column_list ","]\}"
    }
    set cell_meta "[join $row_list ","]"


    ########################################
    # Variable substitution
    ########################################
    set token_vars {filename cell_data formats column_meta row_meta cell_meta}
    set map {}
    foreach token $token_vars {
        lappend map <$token> [set $token]
    }
    set script [string map $map $template]


    ########################################
    # Script execution
    ########################################
    set script_filename [file_temp $script]
    try {
        exec_proxy perl $script_filename
        file delete $script_filename
    } {
        file delete $script_filename
	global errorCode errorInfo errorMessage
	error $errorMessage $errorInfo $errorCode
    }
    return $filename
}

doc excel_file_create {
    Examples {
        set data {
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
            {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
        }
        set formats {
            a {
                "font-family" "Times New Roman"
                "font-size" "12"
                "color" "white"
                "font-weight" "bold"
                "font-style" "italic"
                "text-decoration" "underline"
                "text-align" "center"
                "vertical-align" "top"
                "background-color" "blue"
                "border" "2px solid red"
            }
            b {
                "border-bottom" "1px double blue"
                "text-decoration" "line-through"
            }
        }
        set column_meta {
            {index 2 class a}
        }
        set row_meta {
            {index 3 height 40 class b}
        }
        set cell_meta {
            {row 0 column 0 type string}
        }

        set filename [qc::excel_file_create ~ data formats column_meta row_meta cell_meta]
        
        ns_set update [ns_conn outputheaders] content-disposition "attachment; filename=test_spreadsheet.xls"
        set mime_type "application/vnd.ms-excel"
        ns_returnfile 200 $mime_type $filename
        file delete $filename
    }
}