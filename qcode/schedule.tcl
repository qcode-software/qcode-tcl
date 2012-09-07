package provide qcode 1.8
package require doc
namespace eval qc {}

proc qc::schedule {args} {
    #| Schedule proc for execution unless already scheduled. Start schedule if it is not already running.
    # Usage:
    # schedule -thread "50 seconds" a_proc_name ?arg? ?arg?
    # schedule -thread "5 minutes" a_proc_name ?arg? ?arg?
    # schedule "1 hour" a_proc_name ?arg? ?arg?
    # schedule "10:15" a_proc_name arg arg
    # schedule "Monday 10:15" a_proc_name arg arg
    args $args -thread -- schedule proc_name args
    
    set switches {}
    if { [info exists thread] } {
	lappend switches -thread
    }

    if { ![schedule_exists $proc_name] } {
	switch -regexp -nocase -matchvar match -- $schedule {
	    {^([0-9]+ +(seconds?|minutes?|hours?)($| +))+} {
		set interval 0
		foreach {value unit} $schedule {
		    if { [regexp -nocase {seconds?} $unit] } {
			set interval [expr {$interval + $value}]
		    } elseif { [regexp -nocase {minutes?} $unit] } {
			set interval [expr {$interval + ($value * 60)}]
		    } elseif { [regexp -nocase {hours?} $unit] } {
			set interval [expr {$interval + ($value * 60 * 60)}]
		    }		    
		}
		ns_schedule_proc {*}$switches $interval $proc_name {*}$args
	    }
	    {^([0-9]{1,2}):([0-9]{2})$} {
		set hour [cast_int [lindex $match 1]]
		set minute [cast_int [lindex $match 2]]
		ns_schedule_daily {*}$switches $hour $minute $proc_name {*}$args
	    }
	    {^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday) +([0-9]{1,2}):([0-9]{2})$} {
		set day [lindex $match 1]
		set dow_map {Sunday 0 Monday 1 Tuesday 2 Wednesday 3 Thursday 4 Friday 5 Saturday 6} 
		set dow [string map -nocase $dow_map $day]
		set hour [cast_int [lindex $match 2]]
		set minute [cast_int [lindex $match 3]]
		ns_schedule_weekly {*}$switches $dow $hour $minute $proc_name {*}$args
	    }
	    default {
		error "Invalid syntax for schedule variable, \"$schedule\""
	    }
	}
	log Notice "Scheduled $proc_name" 
    }
    if { ![schedule_running $proc_name] } {
	schedule_start $proc_name
    }
}

doc qc::schedule {
    Examples {
	% schedule -thread "50 seconds" my_proc
	% schedule -thread "5 minutes" my_proc foo bar
	% schedule "1 hour" another_proc
	% schedule "10:15" daily_tasks yellow
	% schedule "Monday 10:15" monday_tasks
    }
}

proc qc::schedule_id {proc_name} {
    #| Return id for schedule proc_name.    
    foreach schedule [ns_info scheduled] {
	lassign $schedule id . . . . . . . arg
	if { [regexp "^${proc_name}( .*)?" $arg] } {
	    return $id
	}
    }
    error "Could not determine id for scheduled proc \"$proc_name\""
}

proc qc::schedule_exists {proc_name} {
    #| Return true if proc has been scheduled.
    foreach schedule [ns_info scheduled] {
	lassign $schedule . . . . . . . . arg
	if { [regexp "^${proc_name}( .*)?" $arg] } {
	    return true
	}
    }
    return false
}

proc qc::schedule_running {proc_name} {
    #| Return true if schdeule is running.
    foreach schedule [ns_info scheduled] {
	lassign $schedule . flag . . . . . . arg
	if { [regexp "^${proc_name}( .*)?" $arg] } {
	    # Check paused flag has not been set.
	    if { ! ($flag & 16) } {
		return true
	    } 
	    break
	}
    }
    return false
}

proc qc::schedule_stop {proc_name} {
    #| Stop schedule 
    if { [schedule_running $proc_name] } {	
	ns_pause [schedule_id $proc_name]
	log Notice "Schedule $proc_name has been stopped" 
    }
}

proc qc::schedule_start {proc_name} {
    #| Start schedule 
    if { ! [schedule_running $proc_name] } {	
	ns_resume [schedule_id $proc_name]
	log Notice "Schedule $proc_name has been started" 
    }
}
