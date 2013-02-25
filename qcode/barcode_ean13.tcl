package provide qcode 1.17
package require doc
namespace eval qc {
    namespace export qc *
}

proc qc::barcode_ean13 {number_to_encode} {
    #| *Untested* Create an EAN barcode
    if { $number_to_encode == "" || $number_to_encode == 0  } {
	return 1;
    }
    set extra_addon ""
    set encoded_text_addon ""
    set encoded_text ""

    if {[string length $number_to_encode] < 12 || [string length $number_to_encode] == 16 } {
	set number_to_encode "0000000000000"
    }
    
    if {[string length $number_to_encode] == 12 || [string length $number_to_encode] == 13 } {
	set number_to_encode [string range $number_to_encode 0 11]
    }

    if {[string length $number_to_encode] == 14 } {
	set extra_addon [string range $number_to_encode 12 13]
	set number_to_encode [string range $number_to_encode 0 11]
    }
    if {[string length $number_to_encode] == 15 } {
	set extra_addon [string range $number_to_encode 13 14]
	set number_to_encode [string range $number_to_encode 0 11]
    }
    if {[string length $number_to_encode] == 17 } {
	set extra_addon [string range $number_to_encode 12 16]
	set number_to_encode [string range $number_to_encode 0 11] 
    }
    if {[string length $number_to_encode] >= 18 } {
	set extra_addon [string range $number_to_encode 13 17]
	set number_to_encode [string range $number_to_encode 0 11] 
    }
    
    # calculate the check digit
    set check_digit [barcode_ean13_check_digit $number_to_encode]
    
    # calculate leading digit;  
    # convert first char(leading_digit) to ASCII
    scan [string index $number_to_encode 0]  %c leading_digit 
    set leading_digit [expr $leading_digit - 48]
    
    # set the encoding type
    if {$leading_digit == 0} {
	set encoding AAAAAACCCCCC
    } elseif {$leading_digit == 1} {
	set encoding AABABBCCCCCC
    } elseif {$leading_digit == 2} {
	set encoding AABBABCCCCCC
    } elseif {$leading_digit == 3} {
	set encoding AABBBACCCCCC
    } elseif {$leading_digit == 4} {
	set encoding ABAABBCCCCCC
    } elseif {$leading_digit == 5} {
	set encoding ABBAABCCCCCC
    } elseif {$leading_digit == 6} {
	set encoding ABBBAACCCCCC
    } elseif {$leading_digit == 7} {
	set encoding ABABABCCCCCC
    } elseif {$leading_digit == 8} {
	set encoding ABABBACCCCCC
    } elseif {$leading_digit == 9} {
	set encoding AAAAAACCCCCC
    }
    
    # add the check digit to the end of the barcode & remove the leading digit
    set actual_data_to_encode "[string range $number_to_encode 1 11]$check_digit"
    # now we have the total number including the check digit
    set i 1
    foreach digit [split $actual_data_to_encode ""] {
	set current_char [scan $digit %c]
	set current_encoding [string index $encoding [expr $i-1]]
        		
	if {[string match $current_encoding A]} {
	    set current_char [format %c $current_char]
	} elseif {[string match $current_encoding B]} {
	    set current_char [format %c [expr $current_char + 17]]
	} else {
	    # In case of type C
	     set current_char [format %c [expr $current_char + 27]]
	}
	set encoded_text "$encoded_text$current_char"

	if {$i == 1} {
	    # first character
	    set temp $leading_digit
	    if {$leading_digit > 4} {
		set temp_ascii "[expr [scan $temp %c] + 64]"
		set encoded_text "[format %c $temp_ascii]\($current_char"
	    } else {
		set temp_ascii "[expr [scan $temp %c] + 37]"
		set encoded_text "[format %c $temp_ascii]\($current_char"
	    }
	} elseif {$i == 6} {
	    # six character
	    set encoded_text "$encoded_text*"
	} elseif {$i == 12} {
	    # last character
	    set encoded_text "$encoded_text\("
	}
	incr i;
    }



     # process 2 digit extra addon if it exits;
    if {[string length $extra_addon] == 2} {
	set i 0;
	# get encoding type for extra add on
	while {$i <= 99} {
	    if {$extra_addon == $i} {
		set encoding AA
	    }
	    if {$extra_addon == [expr $i +1]} {
		set encoding AB
	    }
	    if {$extra_addon == [expr $i + 2]} {
		set encoding BA
	    }
	    if {$extra_addon == [expr $i + 3]} {
		set encoding BB
	    }
	    set i [expr $i + 4]
	}
	set i 1
	# loop runs upto 2(length of extra addon)
	while {$i <= 2} {
       	    if {$i == 1} {
		set encoded_text_addon " [format %c 43]"
	    }
	    set current_char [expr [scan [string index $extra_addon [expr $i -1] ] %c] - 48]
	    set current_encoding [string index $encoding [expr $i - 1]]
	    
	    if {[string match $current_encoding A]} {
		if {$current_char == 0} {
		    set encoded_text_addon "$encoded_text_addon[format %c 34]"
		} elseif {$current_char == 1} {
		    set encoded_text_addon "$encoded_text_addon[format %c 35]"
		} elseif {$current_char == 2} {
		    set encoded_text_addon "$encoded_text_addon[format %c 36]"
		} elseif {$current_char == 3} {
		    set encoded_text_addon "$encoded_text_addon[format %c 37]"
		} elseif {$current_char == 4} {
		    set encoded_text_addon "$encoded_text_addon[format %c 38]"
		} elseif {$current_char == 5} {
		    set encoded_text_addon "$encoded_text_addon[format %c 44]"
		} elseif {$current_char == 6} {
		    set encoded_text_addon "$encoded_text_addon[format %c 46]"
		} elseif {$current_char == 7} {
		    set encoded_text_addon "$encoded_text_addon[format %c 47]"
		} elseif {$current_char == 8} {
		    set encoded_text_addon "$encoded_text_addon[format %c 58]"
		} elseif {$current_char == 9} {
		    set encoded_text_addon "$encoded_text_addon[format %c 59]"
		}
	    }
	    if {[string match $current_encoding B]} {
		if {$current_char == 0} {
		    set encoded_text_addon "$encoded_text_addon[format %c 122]"
		} elseif {$current_char == 1} {
		    set encoded_text_addon "$encoded_text_addon[format %c 61]"
		} elseif {$current_char == 2} {
		    set encoded_text_addon "$encoded_text_addon[format %c 63]"
		} elseif {$current_char == 3} {
		    set encoded_text_addon "$encoded_text_addon[format %c 64]"
		} elseif {$current_char == 4} {
		    set encoded_text_addon "$encoded_text_addon[format %c 91]"
		} elseif {$current_char == 5} {
		    set encoded_text_addon "$encoded_text_addon[format %c 92]"
		} elseif {$current_char == 6} {
		    set encoded_text_addon "$encoded_text_addon[format %c 93]"
		} elseif {$current_char == 7} {
		    set encoded_text_addon "$encoded_text_addon[format %c 95]"
		} elseif {$current_char == 8} {
		    set encoded_text_addon "$encoded_text_addon[format %c 123]"
		} elseif {$current_char == 9} {
		    set encoded_text_addon "$encoded_text_addon[format %c 125]"
		}
	    }
	    # add in the space & add-on guard pattern
	    if {$i == 1} {
		set encoded_text_addon "$encoded_text_addon[format %c 33]"
	    }
	    incr i;
	}
    }
    

    # process 5 digit extra addon if it exits;
    if {[string length $extra_addon] == 5} {
	# calculate check digit for extra addon 
	set factor 3
	set weighted_total 0
	set i 5
	while {$i >= 1} {
	    set current_char [expr [scan [string index $extra_addon [expr $i -1] ] %c] - 48] 
	    if {$factor == 3} {
		set weighted_total [expr $weighted_total + [expr $current_char * 3]]
	    } elseif {$factor == 1} {
		set weighted_total [expr $weighted_total + [expr $current_char * 9]]
	    }
	    set factor [expr 4 -$factor]
	    set i [expr $i -1]
	}
	set check_digit [expr [scan [string index $weighted_total [expr [string length $weighted_total]-1]]  %c] - 48 ]
	        
	# set the encoding type for extra addon
	if {$check_digit == 0} {
	    set encoding BBAAA
	} elseif {$check_digit == 1} {
	    set encoding BABAA
	} elseif {$check_digit == 2} {
	    set encoding BAABA
	} elseif {$check_digit == 3} {
	    set encoding BAAAB
	} elseif {$check_digit == 4} {
	    set encoding ABBAA
	} elseif {$check_digit == 5} {
	    set encoding AABBA
	} elseif {$check_digit == 6} {
	    set encoding AAABB
	} elseif {$check_digit == 7} {
	    set encoding ABABA
	} elseif {$check_digit == 8} {
	    set encoding ABAAB
	} elseif {$check_digit == 9} {
	    set encoding AABAB
	}
	set i 1;
	# loop runs upto 5(extra add on length)
	while {$i <= 5} {
	    set current_char [expr [scan [string index $extra_addon [expr $i -1] ] %c] - 48]
	    set current_encoding [string index $encoding [expr $i - 1]]
	    if {$i == 1} {
		set encoded_text_addon "[format %c 32][format %c 43]"
	    }
	    
	    if {[string match $current_encoding A]} {
		if {$current_char == 0} {
		    set encoded_text_addon "$encoded_text_addon[format %c 34]"
		} elseif {$current_char == 1} {
		    set encoded_text_addon "$encoded_text_addon[format %c 35]"
		} elseif {$current_char == 2} {
		    set encoded_text_addon "$encoded_text_addon[format %c 36]"
		} elseif {$current_char == 3} {
		    set encoded_text_addon "$encoded_text_addon[format %c 37]"
		} elseif {$current_char == 4} {
		    set encoded_text_addon "$encoded_text_addon[format %c 38]"
		} elseif {$current_char == 5} {
		    set encoded_text_addon "$encoded_text_addon[format %c 44]"
		} elseif {$current_char == 6} {
		    set encoded_text_addon "$encoded_text_addon[format %c 46]"
		} elseif {$current_char == 7} {
		    set encoded_text_addon "$encoded_text_addon[format %c 47]"
		} elseif {$current_char == 8} {
		    set encoded_text_addon "$encoded_text_addon[format %c 58]"
		} elseif {$current_char == 9} {
		    set encoded_text_addon "$encoded_text_addon[format %c 59]"
		}
	    }
	    if {[string match $current_encoding B]} {
		if {$current_char == 0} {
		    set encoded_text_addon "$encoded_text_addon[format %c 122]"
		} elseif {$current_char == 1} {
		    set encoded_text_addon "$encoded_text_addon[format %c 61]"
		} elseif {$current_char == 2} {
		    set encoded_text_addon "$encoded_text_addon[format %c 63]"
		} elseif {$current_char == 3} {
		    set encoded_text_addon "$encoded_text_addon[format %c 64]"
		} elseif {$current_char == 4} {
		    set encoded_text_addon "$encoded_text_addon[format %c 91]"
		} elseif {$current_char == 5} {
		    set encoded_text_addon "$encoded_text_addon[format %c 92]"
		} elseif {$current_char == 6} {
		    set encoded_text_addon "$encoded_text_addon[format %c 93]"
		} elseif {$current_char == 7} {
		    set encoded_text_addon "$encoded_text_addon[format %c 95]"
		} elseif {$current_char == 8} {
		    set encoded_text_addon "$encoded_text_addon[format %c 123]"
		} elseif {$current_char == 9} {
		    set encoded_text_addon "$encoded_text_addon[format %c 125]"
		}
	    }
	     # add in the space & add-on guard pattern
	    if {$i < 5} {
		set encoded_text_addon "$encoded_text_addon[format %c 33]"
	    }
	    incr i
	}
    }
    return "$encoded_text$encoded_text_addon"
  
    
}

proc qc::barcode_ean13_check_digit { number } {
    # helper proc
     set odd 1
     set sum 0
     foreach digit [split $number ""] {
         set odd [expr {!$odd}];
         #puts "$sum += ($odd*2+1)*$digit :: [expr {($odd*2+1)*$digit}]"
         incr sum [expr {($odd*2+1)*$digit}]
     }
     set check [expr {$sum % 10}]
     if { $check > 0 } {
         return [expr {10 - $check}]
     }
  return $check
}
