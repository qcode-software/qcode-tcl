# Copyright (C) 2001-2006, Bernhard van Woerden <bernhard@qcode.co.uk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /var/lib/cvs/exf/tcl/format.tcl,v 1.7 2003/03/01 18:14:49 nsadmin Exp $

proc qc::format_commify {number} {
    #| Commify number into groups of three 2314 -> 2,314
    while {[regsub {^([-+]?\d+)(\d\d\d)} $number {\1,\2} number]} {}
    return $number
}

doc format_commify {
    Examples {
	% format_commify 2314
	2,314
	%
	% format_commify 865425833.2354
	865,425,833.2354
    }
}

proc qc::format_money { value } {
    return [format_commify [round $value 2]]
}

doc format_money {
    Examples {
	% format_money 2314
	2,314.00
	%
	% format_money 865425833.2354
	865,425,833.24
    }
}

proc qc::format_dec { value dec_places } {
    #| Round and commify decimal
    #| 2314.235 -> 2,314.24
    return [format_commify [qc::round $value $dec_places]]
}

doc format_dec {
    Examples {
	% format_dec 2314 3
	2,314.000
	%
	% format_dec 865425833.2354 3
	865,425,833.235
    }
}

proc qc::format_int {value} {
    # Round to integer and commify
    # 2314.235 -> 2,314
    return [format_commify [qc::round $value 0]]
}

doc format_int {
    Examples {
	% format_int 2.69
	3
	%
	% format_int 865425833.2354
	865,425,833
    }
}

proc qc::format_linebreak {string width} {
    #| Split $string into a list of lines without exceeding $width
    #| Avoid splitting words
    set result {}
    while {[string length $string]>$width} {
	set position [string last " " $string $width]
	if { $position <=0 } {
	    set position $width
	    lappend result [string range $string 0 [expr {$position-1}]]
	    set string [string range $string $position end]
	} else {
	    lappend result [string range $string 0 [expr {$position-1}]]
	    set string [string range $string [expr {$position+1}] end]
	}
      
    }
    lappend result $string
}

doc format_linebreak {
    Examples {
	% set string {Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.}
	% 
	% format_linebreak $string 80
	{Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor } {incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis } {nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. } {Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu } {fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in } {culpa qui officia deserunt mollit anim id est laborum.}
	%
	%  join [format_linebreak $string 80] \n
	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
	incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis 
	nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
	Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu 
	fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in 
	culpa qui officia deserunt mollit anim id est laborum.
	%
    }
}

proc qc::format_cc {cc_no} {
    #| Format a credit card number in groups of 4 digits
    #| strip non digits
    regsub -all {[^0-9]} $cc_no {} cc_no
    return [join [format_linebreak $cc_no 4] " "]
}

doc format_cc {
    Examples {
	% format_cc 4111111111111111
	4111 1111 1111 1111
	% format_cc "4111 1111 1111 1111"
	4111 1111 1111 1111
    }
}

proc qc::format_ordinal {number} {
    #| Format number with suffix 23 -> 23rd or 4 -> 4th
    # Taken from TCL Wiki RS
    set suffix th
    if {($number%100)<10 || ($number%100)>20} {
	switch -- [expr abs($number)%10] {
	    1 {set suffix st}
	    2 {set suffix nd}
	    3 {set suffix rd}
	}
    }
    append number $suffix
}

doc format_ordinal {
    Examples {
	% format_ordinal 23
	23rd
	% format_ordinal 4
	4th
    }
}

proc qc::format_right0 {string width} {
    #| Right justified padded with leading 0's
    return [format "%0${width}.${width}s" $string]
}

doc format_right0 {
    Examples {
	% format_right0 675 6
	000675
    }
}

proc qc::format_left {string width} {
    #| Padd with spaces left justified
    return [format "%-${width}.${width}s" $string]
}

doc format_left {
    Examples {
	% puts ">>[format_left Dunstable 10]<<"
	>>Dunstable <<
	% format_left Dunstable 6
	Dunsta
    }
}

proc qc::format_right {string width} {
    # Pad with spaces right justified
    return [format "%${width}.${width}s" $string]
}

doc format_right {
    Examples {
	% puts ">>[format_right Dunstable 10]<<"
	>> Dunstable<<
	% format_right Dunstable 6
	Dunsta
    }
}

proc qc::format_center { string width } {
    #| Pad string with spaces to be aligned centrally
    if { [string length $string]<$width } {
	append string [string repeat " " [expr {($width - [string length $string])/2}]]
    }
    return [format "%${width}.${width}s" $string]
}

proc qc::format_bool { value {true Yes} {false No}} {
    #| Cast boolean and wrap in span tags with style
    if { [string is true -strict $value] } {
	return "<span class=\"clsTrue\">$true</span>"
    } else {
	return "<span class=\"clsFalse\">$false</span>"
    }
}

doc format_bool {
    Examples {
	% format_bool Y 
	<span class="clsTrue">Yes</span>
	%
	% format_bool No Aye Nay
	<span class="clsFalse">Nay</span>
    }
}

proc qc::format_yesno { value } {
    #| Call format_bool with default Yes/No
    return [format_bool $value Yes No]
}

proc qc::format_number {args} {
    #| format a number
    args $args -dp ? -sigfigs ? -commify yes -- value
    if { [info exists sigfigs] } {
	set value [sigfigs $value $sigfigs]
    }
    if { [info exists dp] } {
	set value [round $value $dp]
    }
    if { [true $commify] } {
	set value [format_commify $value]
    } 
    return $value
}

proc qc::format_if_number {args} {
    #| If value is a number then commify
    args $args -dp ? -sigfigs ? -zeros yes -commify yes -- value
    if { [is_decimal $value] } {
	if { [info exists sigfigs] && [is_integer $sigfigs]} {
	    set value [sigfigs $value $sigfigs]
	}
	if { [info exists dp] && [is_integer $dp] } {
	    set value [round $value $dp]
	}
	if { !$zeros && $value==0 } {
	    set value ""
	}
	if { [true $commify] } {
	    set value [format_commify $value]
	} 
    }
    return $value
}

doc format_if_number {
    Examples {
	% format_if_number 65242
	65,242
	% format_if_number Total
	Total
    }
}
