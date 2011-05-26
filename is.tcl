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
# $Header: /var/lib/cvs/exf/tcl/qc::validate.tcl,v 1.8 2003/03/27 11:26:23 nsadmin Exp $

proc qc::is_boolean {bool} {
    return [in {Y N YES NO TRUE FALSE T F 0 1} [upper $bool]]
}

proc qc::is_integer {int} {
    if { [string is integer -strict $int] } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pos {number} {
    if { [is_decimal $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz {number} {
    if { [is_decimal $number] && $number>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_integer {int} {
    if { [is_integer $int] && $int!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero {number} {
    if { [is_decimal $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_int { int } {
    # positive non zero integer
    if { [is_integer $int] && $int > 0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_decimal { number } {
    if { [string is double -strict $number]} {
	return 1
    } else {
	return 0
    }
}

proc qc::is_positive_decimal { number } {
    if { [string is double -strict $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_decimal { number } {
    if { [string is double -strict $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_decimal { price } {
    # positive non-zero double
    if { [string is double -strict $price] && $price>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_date { date } {
    # dates are expected to be in iso format 
    return [regexp {^\d{4}-\d{2}-\d{2}$} $date]   
}

proc qc::is_email { email } {
    return [regexp {^[a-zA-Z0-9_\-.]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$} $email]
}

proc qc::is_postcode { postcode } {
    return [expr [regexp {^[A-Z]{1,2}[0-9]{1,2}[A-Z]? ?[0-9][A-Z][A-Z]$} $postcode] || [regexp {^BFPO ?[0-9]+$} $postcode]]
}

proc qc::is_creditcard { no } {
    regsub -all {[ -]} $no "" no
    set mult 1
    set sum 0
    if { [string length $no]<13 || [string length $no]>19 } {
	return 0
    }
    foreach digit [lreverse [split $no ""]] {
	if { ![is_integer $digit] } {
	    return 0
	}
	set t [expr {$digit*$mult}]
	if { $t >= 10 } {
	    set sum [expr $sum + $t%10 +1]
	} else {
	    set sum [expr $sum + $t]
	}
	if { $mult == 1 } { set mult 2 } else { set mult 1 }
    }
    if { $sum%10 == 0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_varchar {string length} {
    if { [string length $string]<=$length } {
	return 1
    } else {
	return 0
    }
}

proc is_base64 {string} {
    if { [regexp {^[A-Za-z0-9/+\r\n]+=*$} $string] \
	&& ([string length $string]-[regexp -all -- \r?\n $string])*6%8==0 } {
	return 1
    } else {
	return 0
    }
}

proc is_int_castable {string} {
    try {
	cast_integer $string
	return true
    } {
	return false
    }
}


proc is_decimal_castable {string} {
    try {
	cast_decimal $string
	return true
    } {
	return false
    }
}

proc is_date_castable {string} {
    try {
	cast_date $string
	return true
    } {
	return false
    }
}

proc is_timestamp_castable {string} {
    try {
	cast_timestamp $string
	return true
    } {
	return false
    }
}

proc is_mobile_number {string} {
    # mobile telephone number
    regsub -all {[^0-9]} $string {} tel_no
    if {  [regexp {^07(5|7|8|9)[0-9]{8}$} $tel_no] } {
	return true
    } else {
	return false
    }
}

proc contains_creditcard {string} {
    set cc_no_pattern {(?:^|[^\.\+0-9])([3456](?:\d[ \-\.]*){11,17}\d)(?:[^0-9]|$)}
    
    append context_filter \
	{(^[^\.\+0-9a-z]*([3456](\d[ \-\.]*){11,17}\d)[^0-9a-z]*$)}\
	| {(^|[^\.\+0-9])([3456](\d[ \-\.]*){11,17}\d)[^0-9a-z]+([a-z]*[^0-9a-z]*\d{1,2}[^0-9a-z]*(20\d\d|\d\d)[^0-9a-z]+){1,2}[a-z]*[^0-9a-z]*\d{3,4}($|[^0-9])}\
	| {((^|[^a-z])(visa|mastercard|card|expiry|american express)($|[^a-z]))}\
	| {(^|[^/0-9])(\d\d/\d\d|\d\d/20\d\d)([^/0-9]|$)}
    
    set exclude_filter {((^|[^a-z])(tlc credit account)($|[^a-z]))}

    if { [regexp -nocase $context_filter $string] \
	     && [regexp -nocase $exclude_filter $string]==0 } {

	set indices [regexp -inline -indices -all $cc_no_pattern $string]
	
	foreach {. item} $indices {     
	    set suspect_str [string range $string [lindex $item 0] [lindex $item 1]]
	    set suspect_no [string map {" " "" - "" . ""} $suspect_str]
    
	    if { [regexp {^[0-9]+(\.|\-)[0-9]+$} $suspect_str]==0 && [is_creditcard $suspect_no] } {
		return true
	    }
	}
    }
    return false
}