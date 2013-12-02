package provide qcode 2.4.0
package require doc
namespace eval qc {
    namespace export style_set css_parse css_rule2dict
}

proc qc::style_set {rule args} {
    # example 
    # > qc::style_set "color:pink;font-weight:bold;" color green
    # color:green;font-weight:bold
    set rule [string trim $rule ";"]
    set dict [split $rule ";:"]
    foreach {property value} $args {
	if {[in {width height top left right bottom} $property] && [is_integer $value]} {
	    # add units px for bare integers
	    append value px
	}
	dict set dict $property $value
    }
    set list {}
    foreach {property value} $dict {
	lappend list "$property:$value"
    }
    return [join $list ";"]
}
    
proc qc::css_parse {css} {
    # remove comments
    regsub -all {/\*((\*[^/])|[^*])*\*?\*/} $css {} css
    # Remove @ media sections 
    # may handle them at a later date 
    regsub -all {@media [^\{]+\{([^\{]+\{[^\}]+\}[ \t\r\n]*)+\}} $css {} css
    set data {}
    foreach rule [regexp -all -inline {[^\{]+\{[^\}]+\}} $css] {
	regexp {([^\{]+)\{([^\}]+)\}} $rule -> selector declaration
	regsub -all {[\t\r\n]} $declaration {} declaration
	regsub -all { *: *} $declaration {:} declaration
	regsub -all { *; *} $declaration {;} declaration
	set declaration [string trim $declaration "; "]
	set selector [string trim $selector]
	set dict [split $declaration ";:"]
	lappend data $selector $dict
    }
    return $data
}
    
proc qc::css_rule2dict {rule} {
    set rule [string trim $rule ";"]
    set dict [split $rule ";:"]
}




