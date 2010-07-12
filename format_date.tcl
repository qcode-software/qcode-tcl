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
# $Header: /home/bernhard/cvs/exf/tcl/format.tcl,v 1.11 2003/10/25 14:34:46 bernhard Exp $

proc qc::format_date { date } {
    #| Format a date for the user
    #| Will be customizable in future but at present chooses the ISO format.
    return [string map [list - "&#8209;"] [clock format [cast_epoch $date] -format "%Y-%m-%d"]]
}

doc format_date {
    Parent date
    Examples {
	% format_date "23rd June 2008"
	% 2008-06-23
	%
	% format_date 2/5/08
	% 2008-05-02
    }
}

proc qc::format_date_iso { date } {
    #| Format a date as an ISO 8601 string like 2006-04-28
    return [clock format [cast_epoch $date] -format "%Y-%m-%d"]
}

doc format_date_iso {
    Parent date
    Examples {
	% format_date "23rd June 2008"
	% 2008-06-23
	%
	% format_date 2/5/08
	% 2008-05-02
    }
}

proc qc::format_date_uk { date } {
    #| Format a date in UK format e.g. 27/03/07
    return [clock format [cast_epoch $date] -format "%d/%m/%y"]
}

doc format_date_uk {
    Parent date
    Examples {
	% format_date_uk 2008-06-23
	23/06/08
	% 
	% format_date_uk today
	17/10/07
    }
}

proc qc::format_date_uk_long { date } {
    #| Format a date in UK format with a 4 digit year e.g. 27/03/2007
    return [clock format [cast_epoch $date] -format "%d/%m/%Y"]
}

doc format_date_uk_long {
    Parent date
    Examples {
	% format_date_uk 2008-06-23
	23/06/2008
	% 
	% format_date_uk today
	17/10/2007
    }
}

proc qc::format_date_rel { date } {
    #| Format the date relatively depending on age
    #| dates this month -> Wed 3rd
    #| dates this year -> JUN 3rd
    set epoch [cast_epoch $date]
    set epoch_now [clock seconds]
    # Today 
    if { [string equal [clock format $epoch_now -format "%Y-%m-%d"] [clock format $epoch -format "%Y-%m-%d"]] } {
        return "Today"
    }
    if { [string equal [clock format $epoch_now -format "%Y"] [clock format $epoch -format "%Y"]] } {
	# this year
	if { [string equal [clock format $epoch_now -format "%m"] [clock format $epoch -format "%m"]] } {
	    # same month
	    set dom [clock format $epoch -format "%e"]
	    set dow [clock format $epoch -format "%a"]
	    return "$dow [format_ordinal $dom]"; # Wed 3rd
	} else {
	    set dom [clock format $epoch -format "%e"] 
	    set mon [string toupper [clock format $epoch -format "%b"]]
	    return "$mon [format_ordinal $dom]"; # JUN 3rd
	}
    } else {
	return [clock format $epoch -format "%Y-%m-%d"]; # 2007-05-06
    }
}

doc format_date_rel {
    Parent date
    Examples {
	% format_date_rel now
	Today
	% 
	% format_date_rel tomorrow
	Thu 18th
	%
	% format_date_rel "next month"
	NOV 17th
	%
	% format_date_rel "next year"
	2008-10-17
    }
}

proc qc::format_date_letter { date } {
    #| Format a date as would be used on a letter
    # 2007-04-12 -> 12th April 2007
    set epoch [cast_epoch $date]
    set dom [clock format $epoch -format "%e"] 
    return "[format_ordinal $dom] [clock format $epoch -format "%B %Y"]"
}

doc format_date_letter {
    Parent date
    Examples {
	% format_date_letter now
	17th October 2007
    }
}
