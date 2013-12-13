package provide qcode 2.6.4
package require doc
namespace eval qc {
    namespace export barcode128 barcode128partB barcode128partC barcode_charcode barcode_charcode_html
}

proc qc::barcode128 {string} {
    #| Make a code128 barcode
    # encode 4 or more consecutive numbers in code C
    # data is char value char value ..... pairs
    set data {}
    while { [string length $string] } {
	if {[regexp {^(([^0-9]+[0-9]{0,3}[^0-9]+)+)(.*)$} $string -> partB . string]} {
	    # e.g A123A
	    if { [llength $data] } {
		# already started so change-to-B char needed
		lappend data [barcode_charcode_html 200] 100
	    } else {
		# Start char for 128 B has value 104 
		lappend data [barcode_charcode_html 204] 104
	    }
	    set data [concat $data [qc::barcode128partB $partB]]
	} elseif {[regexp {^(([0-9]{0,3}[^0-9]+)+)(.*)$} $string -> partB . string]} {
	    # e.g. 123A
	    if { [llength $data] } {
		# already started so change-to-B char needed
		lappend data [barcode_charcode_html 200] 100
	    } else {
		# Start char for 128 B has value 104 
		lappend data [barcode_charcode_html 204] 104
	    }
	    set data [concat $data [barcode128partB $partB]]
	} elseif { [regexp {^([0-9]+)(.*)$} $string -> partC string] } {
	    if { [llength $data] } {
		# already started so change-to-C char needed
		lappend data [barcode_charcode_html 199] 99
	    } else {
		# Start char for 128 C has value 105
		lappend data [barcode_charcode_html 205] 105
	    }
	    set data [concat $data [barcode128partC $partC]]
	} else {
	    error "No match"
	}
    }
    # checksum
    set i 0
    set sum [lindex $data 1]
    set barcode ""
    foreach {char value} $data {
	set sum [expr {$sum + $i*$value}]
	incr i
	append barcode $char
    }
    set check_value [expr {$sum%103}]
    append barcode [barcode_charcode_html $check_value]
    # End char is unicode 206
    append barcode [barcode_charcode_html 206]
    return $barcode
}

proc qc::barcode128partB { string } {
    # Encode ASCII as 128B
    set lstring [split $string ""]
    set data {}
    foreach char $lstring {
	# map ASCII to barcode 128
	binary scan $char c charcode
	set value [expr {$charcode-32}]
	lappend data [barcode_charcode_html $value] $value
    }
    return $data
}

proc qc::barcode128partC {string} {
    #| Encode as 128C
    # If the number does not have an even number of digits
    # then prepend a zero
    if { [string length $string]%2 != 0 } {
	set string "0$string"
    }   
    foreach {a b} [split $string ""] {
	set value "$a$b"
	# Convert eg 08 to 8
	scan $value %d value
	lappend data [barcode_charcode_html $value] $value
    }
    return $data
}

proc qc::barcode_charcode { value } {
    #| Return the corresponding charcode. This is specific to the font set used.
    if { $value == 0 } {
	# space
	return 194
    }
    if { $value > 0 && $value < 95 } {
	return [expr {$value+32}]
    }
    if { $value > 94 && $value < 106} {
	return [expr {$value+100}]
    }
}

proc qc::barcode_charcode_html { value } {
    #| Translate to HTML entities 
    if { $value == 0 } {
	# space
	return "&#194;"
    }
    if { $value > 0 && $value < 95 } {
	#return [format %c [expr {$value+32}]]
	return "&#[expr {$value+32}];"
    }
    if { $value > 94 && $value < 106} {
	return "&#[expr {$value+100}];"
    }
}
