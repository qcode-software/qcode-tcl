namespace eval qc {
    namespace export excel_*
}

proc qc::excel_file_create {args} {
    #| Creates an xls or xlsx file using the information provided
    # type: "xls" or "xlsx", defaults to "xlsx"
    # data: a list of lists containing a grid of cell values
    # formats: a dict of class definitions
    # class definitions: a dict of name-value pairs
    # column_meta: nested dict, eg. {1 {class "foo" width 20} 5 {width 50}}
    # row_meta: nested dict, eg. {0 {class "bar" height 20} 3 {class "foo"}}
    # cell_meta: nested dict, eg. {
    #   {5 2} {class "baz" type "string|number|formula|url"}
    #   {1 1} {class "bar"}
    # }
    # images: ldict, eg. {
    #   {filename /tmp/foo.png row 1 col 5}
    #   {filename /tmp/bar.png row 2 col 3 x 5 y 10 x_scale 1.2 y_scale 1.3}
    # }
    qc::args2vars $args {*}{
        data
        formats
        column_meta
        row_meta
        cell_meta
        timeout
        type
        images
    }
    default {*}{
        data {}
        formats {}
        column_meta {}
        row_meta {}
        cell_meta {}
        timeout 1000
        type "xlsx"
        images {}
    }
    switch $type {
        "xls" {
            set writer "Spreadsheet::WriteExcel"
        }
        "xlsx" {
            set writer "Excel::Writer::XLSX"
        }
        default {
            error "Unsupported excel type"
        }
    }

    set filename [qc::file_temp ""]
    ########################################
    # Template
    ########################################
    set template {#!/usr/bin/perl -w
        use strict;
        use <writer>;

        ####################
        # Data
        ####################

        # Insert filename here
        my $workbook = <writer>->new('<filename>');
        my $worksheet = $workbook->add_worksheet();

        # Cell data, eg.
        # my $data = [
        #    ["name", "DOB", "Telephone"],
        #    ["Bob", "12/12/12", "1234 5678"],
        #    ["Jane", "01/01/01", "0123 9876"]
        # ];
        my $data = <cell_data>;

        # Workbook formats, eg.
        # my $formats = {
        #    highlight {
        #        bold => 1,
        #        color => 'green'
        #    },
        #    error => {
        #        color => 'red'
        #    }
        # };
        my $formats = <formats>;

        # Column meta-data, eg.
        # my $column_meta = {
        #    0 => {
        #        class => "red",
        #        width => 30
        #    }
        # };
        my $column_meta = <column_meta>;

        # Row meta-data, eg.
        # my %row_meta = {
        #    0 => {
        #        class => "bold",
        #        height => 25
        #    }
        # };
        my $row_meta = <row_meta>;

        # Cell meta-data, eg.
        # my %cell_meta = {
        #    2 => {
        #        1 => {
        #            class => "red",
        #            type => "string"
        #        },
        #        2 => {
        #            class => "bold"
        #        }
        #    }
        # };
        my $cell_meta = <cell_meta>;

        # Images, eg.
        # my $images = [
        #   {
        #     filename => /tmp/foo.png,
        #     row => 1,
        #     col => 5,
        #   },
        #   {
        #     filename => /tmp/bar.png,
        #     row => 2,
        #     col => 3,
        #     x => 5,
        #     y => 10,
        #     x_scale => 1.2,
        #     y_scale => 1.3
        #   }
        # ];
        my $images = <images>;

        ####################
        # Logic
        ####################
        # Formats
        my $format_objects = {};
        foreach my $class ( keys %{$formats} ) {
            $format_objects->{$class} = $workbook->add_format(%{$formats->{$class}});
        }

        # Column meta
        foreach my $i ( keys %{$column_meta} ) {
            my $format;
            if ( exists $column_meta->{$i}{"class"} ) {
                $format = $format_objects->{$column_meta->{$i}{"class"}};
            }
            my $width = $column_meta->{$i}{"width"};
            $worksheet->set_column($i, $i, $width, $format);
        }

        # Row meta
        foreach my $i ( keys %{$row_meta} ) {
            my $format;
            if ( exists $row_meta->{$i}{"class"} ) {
                $format = $format_objects->{$row_meta->{$i}{"class"}};
            }
            my $height = $row_meta->{$i}{"height"};
            $worksheet->set_row($i, $height, $format);
        }

        # Cells
        $worksheet->keep_leading_zeros();
        for my $i ( 0 .. $#{$data} ) {
            for my $j ( 0 .. $#{ $data->[$i] } ) {
                my $format;
                my $type;
                if ( exists $cell_meta->{$i}{$j}{"class"} ) {
                    $format = $format_objects->{$cell_meta->{$i}{$j}{"class"}};
                }
                if ( exists $column_meta->{$j}{"type"} ) {
                    $type = $column_meta->{$j}{"type"};
                }
                if ( exists $row_meta->{$i}{"type"} ) {
                    $type = $row_meta->{$i}{"type"};
                }
                if ( exists $cell_meta->{$i}{$j}{"type"} ) {
                    $type = $cell_meta->{$i}{$j}{"type"};
                }

                if ( ! defined $type ) {
                    # Guess type based on value
                    $worksheet->write($i, $j, $data->[$i][$j], $format);

                } elsif ( $type eq "string" ) {
                    $worksheet->write_string($i, $j, $data->[$i][$j], $format);

                } elsif ( $type eq "number" ) {
                    $worksheet->write_number($i, $j, $data->[$i][$j], $format);

                } elsif ( $type eq "formula" ) {
                    $worksheet->write_formula($i, $j, $data->[$i][$j], $format);

                } elsif ( $type eq "url" ) {
                    my $url = $cell_meta->{$i}{$j}{"url"};
                    $worksheet->write_url($i, $j, $url, $data->[$i][$j], $format);
                }
            }
        }

        # Images
        for my $i ( 0 .. $#{$images} ) {
            if ( not ( exists $images->[$i]{"x"} && exists $images->[$i]{"y"} ) ) {
                $worksheet->insert_image(
                                         $images->[$i]{"row"},
                                         $images->[$i]{"col"},
                                         $images->[$i]{"filename"});
            } elsif ( not ( exists $images->[$i]{"x_scale"}
                            && exists $images->[$i]{"y_scale"} )
                      ) {
                $worksheet->insert_image(
                                         $images->[$i]{"row"},
                                         $images->[$i]{"col"},
                                         $images->[$i]{"filename"},
                                         $images->[$i]{"x"},
                                         $images->[$i]{"y"});                
            } else {
                $worksheet->insert_image(
                                         $images->[$i]{"row"},
                                         $images->[$i]{"col"},
                                         $images->[$i]{"filename"},
                                         $images->[$i]{"x"},
                                         $images->[$i]{"y"},
                                         $images->[$i]{"x_scale"},
                                         $images->[$i]{"y_scale"});
            }
        }
    }
    # End of template

    ########################################
    # Perl Data
    ########################################
    # Cell data - A list of list becomes an array of arrays
    set cell_data [llist2perl_aarray $data]
    
    # Formats - a dict of dicts becomes a hash of format objects added to the current workbook
    set formats [qc::excel_formats $formats]

    # Colum meta-data - a dict of dicts becomes a hash of hashes
    set column_meta [qc::ddict2perl_hhash $column_meta]

    # Row meta-data - a dict of dicts becomes a hash of hashes
    set row_meta [qc::ddict2perl_hhash $row_meta]

    # Cell meta-data - a dict of dicts with lists for keys becomes a hash of hashes of hashes
    set cell_meta [qc::cell_meta2perl $cell_meta]

    # Images - An ldict becomes an array of hashes
    set images [qc::ldict2perl_ahash $images]

    ########################################
    # Variable substitution
    ########################################
    set token_vars {
        writer
        filename
        cell_data
        formats
        column_meta
        row_meta
        cell_meta
        images
    }
    set map {}
    foreach token $token_vars {
        lappend map <$token> [set $token]
    }
    set script [string map $map $template]

    ########################################
    # Script execution
    ########################################
    set script_filename [qc::file_temp $script]
    ::try {
        log Debug $script_filename
        exec_proxy -timeout $timeout perl $script_filename
        file delete $script_filename
    } on error {error_message options} {
        file delete $script_filename
        error $error_message [dict get $options -errorinfo] [dict get $options -errorcode]
    }
    return $filename
}

proc qc::excel_formats {class_defs} {
    #| Converts a nested dict of class definitions to a perl hash of excel formats
    set format_dict {}
    dict for {class format} $class_defs {
        dict set format_dict $class [qc::excel_format $format]
    }
    return [ddict2perl_hhash $format_dict]
}

proc qc::excel_format {format} {
    #| Prepare a format defn for the Perl Lib
    set format_list {}
    dict for {attribute value} $format {
        switch $attribute {
            "font-family" {
                dict set attribute_dict font $value
            }
            "font-size" {
                dict set attribute_dict size $value
            }
            "font-weight" {
                if {$value eq "bold"} {
                    dict set attribute_dict bold 1
                } else {
                    error "$css_attribute $css_value is unsupported"
                }
            }
            "font-style" {
                if {$value eq "italic"} {
                    dict set attribute_dict italic 1
                } else {
                    error "$css_attribute $css_value is unsupported"
                }
            }
            "text-decoration" {
                switch $value {
                    "underline" {
                        dict set attribute_dict underline 1
                    }
                    "line-through" {
                        dict set attribute_dict font_strikeout 1
                    }
                    default {
                        error "$css_attribute $css_value is unsupported"
                    }
                }
            }
            "text-align" {
                dict set attribute_dict align $value
            }
            "vertical-align" {
                if {$value eq "middle"} {
                    dict set attribute_dict valign vcenter
                } else {
                    dict set attribute_dict valign $value
                }
            }
            "background" -
            "background-color" {
                dict set attribute_dict bg_color $value
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
                dict set attribute_dict $side $index
                dict set attribute_dict ${side}_color $color
            }
            default {
                dict set attribute_dict $attribute $value
            }
        }
    }
    return $attribute_dict
}

proc qc::cell_meta2perl {cell_meta} {
    #| Converts excel cell meta data from a nested dict to a perl hash of hashes
    set cell_meta_nested {}
    dict for {indices cell} $cell_meta {
        set row [lindex $indices 0]
        set column [lindex $indices 1]
        dict set cell_meta_nested $row $column $cell
    }
    set row_hash_list {}
    dict for {row row_data} $cell_meta_nested {
        lappend row_hash_list "$row => [ddict2perl_hhash $row_data]"
    }
    return \{[join $row_hash_list ", "]\}
}
