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

proc qc::format_timestamp_iso { string } {
    #| Format string as an ISO timestamp 
    return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]]
}

doc format_timestamp_iso {
    Examples {
	% format_timestamp_iso now
	2007-11-05 17:30:14
	%
	% format_timestamp_iso "23/5/2008 10:11:28"
	2008-05-23 10:11:28
	%
	% format_timestamp_iso "23rd June 2008 10:11"
	2008-06-23 10:11:00
    }
}

proc qc::format_timestamp_rel { string } {
    #| Format relative to age with date and time
    set epoch [cast_epoch $string]
    set epoch_now [clock seconds]
    # Today return time
    if { [string equal [cast_date $epoch_now] [cast_date $epoch]] } {
        return [clock format $epoch -format "%H:%M"]
    }
    # Same Week
    if { [string equal [clock format $epoch_now -format "%Y%U"] [clock format $epoch -format "%Y%U"]] } {
        return [clock format $epoch -format "%a %H:%M"]
    }
    # Same Year
    if { [string equal [clock format $epoch_now -format "%Y"] [clock format $epoch -format "%Y"]] } {
	return "[date_month_shortname $epoch] [format_ordinal [date_dom $epoch]]"
    }
    return [clock format $epoch -format "%Y-%m-%d"]
}

doc format_timestamp_rel {
    Examples {
	% format_timestamp_rel now
	17:33
	%
	% format_timestamp_rel yesterday
	Sun 17:34
	%
	% format_timestamp_rel "next week"
	2007-11-12 17:34
    }
}

proc qc::format_timestamp2hour { string } {
    return [string map [list - "&#8209;"] [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M"]]
}

proc qc::format_timestamp { string } {
    #| Format string as datetime for user.
    #| Will be customizable in future but at present chooses the ISO format.
    return [format_timestamp_iso $string]
}

doc format_timestamp {
    Examples {
	% format_timestamp now
	2007-11-05 17:30:14
	%
	% format_timestamp "23/5/2008 10:11:28"
	2008-05-23 10:11:28
	%
	% format_timestamp "23rd June 2008 10:11"
	2008-06-23 10:11:00
    }
}