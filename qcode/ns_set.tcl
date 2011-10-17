package provide qcode 1.1
package require doc
namespace eval qc {}
proc qc::ns_set_to_vars { set_id {level 0}} {
    #| Take an ns_set with id $set_id from caller 
    #| and place variables in level $level.
    incr level
    foreach {key value} [ns_set array $set_id] {
	upset $level $key $value
    }
}

proc qc::ns_set_to_dict { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return a dict
    return [ns_set array $set_id]
}

proc qc::ns_set_to_multimap { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return a multimap of key values pairs
    return [ns_set array $set_id]
}

proc qc::ns_set_getall { set_id key } {
    #| Take an ns_set with id $set_id from caller 
    #| return all values for the key given
    set values {}
    if { ![string equal $set_id ""] } {
	set size [ns_set size $set_id]
	for {set i 0} {$i<$size} {incr i} {
	    if {[eq [ns_set key $set_id $i] $key]} {
		lappend values [ns_set value $set_id $i]
	    }
	}
    }
    return $values
}

proc qc::ns_set_keys { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return all keys
    set keys {}
    if { ![string equal $set_id ""] } {
	set size [ns_set size $set_id]
	for {set i 0} {$i<$size} {incr i} {
	    lappend keys [ns_set key $set_id $i]
	}
    }
    return $keys
}

proc qc::ns_set_values { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return all values
    set values {}
    if { ![string equal $set_id ""] } {
	set size [ns_set size $set_id]
	for {set i 0} {$i<$size} {incr i} {
	    lappend values [ns_set value $set_id $i]
	}
    }
    return $values
}

