package provide qcode 2.6.1
package require doc
namespace eval qc {
    namespace export ns_set_*
}

#| Aolserver specific

proc qc::ns_set_to_vars { set_id {level 0}} {
    #| Take an ns_set with id $set_id from caller 
    #| and place variables in level $level.
    incr level
    foreach {key value} [ns_set array $set_id] {
	upset $level $key $value
    }
}

doc qc::ns_set_to_vars {
    Description {
        Take an ns_set with id $set_id from caller and place variables in level $level.
    }
    Usage {
        qc::ns_set_to_vars set_id ?level?
    }
    Examples {
        1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land."]
        d3
        2> qc::ns_set_to_vars $set_id

        3> set to
        you@there.com
        4> set from
        me@here.com
    }
}

proc qc::ns_set_to_dict { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return a dict
    return [ns_set array $set_id]
}

doc qc::ns_set_to_dict {
    Description {
        Take an ns_set with id $set_id from caller return a dict.
    }
    Usage {
        qc::ns_set_to_dict set_id
    }
    Examples {
        1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land."]
        d3
        2> qc::ns_set_to_dict $set_id
        from me@here.com to you@there.com msg {Get off my land.}
    }
}

proc qc::ns_set_to_multimap { set_id } {
    #| Take an ns_set with id $set_id from caller 
    #| return a multimap of key values pairs
    return [ns_set array $set_id]
}

doc qc::ns_set_to_multimap {
    Description {
        Take an ns_set with id $set_id from caller return a multimap of key pairs.
    }
    Usage {
        qc::ns_set_to_multimap set_id
    }
    Examples {
        1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
        2> qc::ns_set_to_multimap  $set_id
        from me@here.com to you@there.com msg {Get off my land.} to andyou@there.com to youtoo@there.com
    }
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

doc qc::ns_set_getall {
    Description {
        Take an ns_set with id $set_id from caller return all values for the key given
    }
    Usage {
        qc::ns_set_getall set_id key
    }
    Examples {
        1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
        d5
        2> qc::ns_set_getall $set_id to
        you@there.com andyou@there.com youtoo@there.com
    }
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

doc qc::ns_set_keys {
    Description {
        Take an ns_set with id $set_id from caller return all keys
    }
    Usage {
        qc::ns_set_keys set_id 
    }
    Examples {
        1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
        d1
        2> qc::ns_set_keys $set_id
        from to msg to to
    }
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

doc qc::ns_set_values {
    Description {
	Take an ns_set with id $set_id from caller return all values
    }
    Usage {
        qc::ns_set_values { set_id } {
	}
	Examples {
	    1> set set_id [ns_set create this_set from me@here.com to you@there.com msg  "Get off my land." to andyou@there.com to youtoo@there.com]
	    d1
	    2>  qc::ns_set_values $set_id
	    me@here.com you@there.com {Get off my land.} andyou@there.com youtoo@there.com
	}
    }
}
