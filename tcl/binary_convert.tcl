package provide qcode 2.03
package require doc
namespace eval qc {}

proc qc::binary_convert_unit_prefix2mult {prefix} {
    #| Return multiplier for a binary unit prefix.
    switch $prefix {
        "" {
            set power 0
        }
        K -
        Ki -
        kilo -
        Kilo -
        kibi -
        Kibi {
            set power 1
        }
        M -
        Mi -
        mega -
        Mega -
        mebi -
        Mebi {
            set power 2
        }
        G -
        Gi -
        giga -
        Giga -
        gibi -
        Gibi {
            set power 3
        }
        T -
        Ti -
        tera -
        Tera -
        tebi -
        Tebi {
            set power 4
        }
        P -
        Pi -
        peta -
        Peta -
        pebi -
        Pebi {
            set power 5
        }
        E -
        Ei -
        exa -
        Exa -
        exbi -
        Exbi {
            set power 6
        }
        Z -
        Zi -
        zetta -
        Zetta -
        zebi -
        Zebi {
            set power 7
        }
        Y -
        Yi -
        yotta -
        Yotta -
        yobi -
        Yobi {
            set power 8
        }        
        default {
            error "Unknown binary unit prefix \"$prefix\""
        }
    }
    
    return [expr {pow(1024,$power)}]
}

doc qc::binary_convert_unit_prefix2mult {
    Examples {
	% qc::binary_convert_unit_prefix2mult K
	1024.0
	% qc::binary_convert_unit_prefix2mult kilo
	1024.0
	% qc::binary_convert_unit_prefix2mult Kilo
	1024.0
	% qc::binary_convert_unit_prefix2mult Ki
	1024.0
	% qc::binary_convert_unit_prefix2mult kibi
	1024.0
	% qc::binary_convert_unit_prefix2mult Kibi
	1024.0
        % qc::binary_convert_unit_prefix2mult M
	1048576.0
	% qc::binary_convert_unit_prefix2mult G
	1073741824.0
    }
}

proc qc::binary_convert {args} {
    #| Convert binary file size units.
    #| Usage: qc::binary_convert size from_unit to_unit
    #|        qc::binary_convert size to_unit
    
    # Parse arguments
    if { [llength $args] == 3 } {
        lassign $args size from_units to_units
    } elseif { [llength $args] == 2 } {
        if { ! [regexp {^([0-9]+) *([^ 0-9]+)$} [lindex $args 0] -> size from_units] } {
            error "Invalid argument \"[lindex $args 0]\". Size must specify units eg. \"1000B\"."
        }
        set to_units [lindex $args 1]        
    } else {
        error "Invalid number of arguments.\nUsage:\nqc::binary_convert size from_unit to_unit\nqc::binary_convert size to_unit"
    }

    # Convert to bits
    if { [regexp {^(.*)(b|(?:bit|Bit)s?)$} $from_units -> unit_prefix] } {
        set unit_prefix_value [qc::binary_convert_unit_prefix2mult $unit_prefix]
        set size [expr {$size * $unit_prefix_value}]
    } elseif { [regexp {^(.*)(B|(byte|Byte)s?)$} $from_units -> unit_prefix] } {
        set unit_prefix_value [qc::binary_convert_unit_prefix2mult $unit_prefix]
        set size [expr {$size * $unit_prefix_value * 8}]
    } else {
        error "Unable to convert from unit \"$from_units\". Units must be in bits or bytes."
    } 
    
    # Convert to to_units
    if { [regexp {^(.*)(b|(?:bit|Bit)s?)$} $to_units -> unit_prefix] } {
        set unit_prefix_value [qc::binary_convert_unit_prefix2mult $unit_prefix]
        set size [expr {double($size) / $unit_prefix_value}]
    } elseif { [regexp {^(.*)(B|(byte|Byte)s?)$} $to_units -> unit_prefix] } {
        set unit_prefix_value [qc::binary_convert_unit_prefix2mult $unit_prefix]
        set size [expr {double($size) / $unit_prefix_value / 8}]
    } else {
        error "Unable to convert to unit \"$to_units\". Units must be in bits or bytes."
    } 

    return $size
}

doc qc::binary_convert {
    Examples {
	% qc::binary_convert 2048 KB MB
	2.0
	% qc::binary_convert "3072MB" GB
	3.0
	% qc::binary_convert "3 GB" kilobyte
	3145728.0
        % qc::binary_convert "3 GibiByte" KibiB
	3145728.0
    }
}

proc qc::binary_format {args} {
    #| Return formatted string to display a binary file size in the most appropriate units.
    #| Usage: qc::binary_format ?-sigfigs sigfigs? size
    #|        qc::binary_format ?-sigfigs sigfigs? size units

    # Parse arguments
    args $args -sigfigs 3 args
    if { [llength $args] == 2 } {
        lassign $args size units
    } elseif { [llength $args] == 1 } {
        if { ! [regexp {^([0-9]+) *([^ 0-9]+)$} [lindex $args 0] -> size units] } {
            error "Invalid argument \"[lindex $args 0]\". Size must specify units eg. \"1000B\"."
        }
    } else {
        error "Invalid number of arguments.\nUsage:\nqc::binary_format ?-sigfigs sigfigs? size\nqc::binary_format ?-sigfigs sigfigs? size units"
    }

    # Convert to prefixed bits or bytes to unit bits or bytes
    if { [regexp {^(.*)(b|(?:bit|Bit)s?)$} $units -> unit_prefix] } {
        set size [qc::binary_convert $size $units b]
        set units b
    } elseif { [regexp {^(.*)(B|(byte|Byte)s?)$} $units -> unit_prefix] } {
        set size [qc::binary_convert $size $units B]
        set units B
    } else {
        error "Unable to parse to unit \"$units\". Units must be in bits or bytes."
    } 

    # Determine the most appropriate unit prefix
    switch [expr {int(log($size)/log(1024))}] {
        0 {
            set unit_prefix ""
        }
        1 {
            set unit_prefix K
        }
        2 {
            set unit_prefix M
        }
        3 {
            set unit_prefix G
        }
        4 {
            set unit_prefix T
        }
        5 {
            set unit_prefix P
        }
        6 {
            set unit_prefix E
        }
        7 {
            set unit_prefix Z
        }
        8 {
            set unit_prefix Y
        }
        default {
            # Make Y the default prefix 
            set unit_prefix Y
        }
    }

    # Convert to desired unit prefix, round to sigfigs and append units to the string
    return "[qc::sigfigs [qc::binary_convert $size $units ${unit_prefix}${units}] $sigfigs] ${unit_prefix}${units}"
}

doc qc::binary_format {
    Examples {
	% qc::binary_format 44444 MB 
	43.4 GB
	% qc::binary_format 44444 MBytes
	43.4 GB
	% qc::binary_format 44444 megabytes 
	43.4 GB
        % qc::binary_format 44444 megabyte
	43.4 GB
	% qc::binary_format "44444Mb"
	43.4 Gb
        % qc::binary_format "44444Mbit"
	43.4 Gb
        % qc::binary_format "44444 megabit"
	43.4 Gb
        % qc::binary_format "44444 megabit"
	43.4 Gb
	% qc::binary_format -sigfigs 5 44444 Mb
	43.402 Gb
    }
}