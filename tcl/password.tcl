package provide qcode 2.4.0
package require doc
namespace eval qc {
    namespace export password_hash password_complexity_ok password_complexity_check
}

proc qc::password_hash { password {strength 7} } {
    #| Returns a salted password hash using blowfish with an iteration count of $strength
    # Strength min is 4 and max is 31
    check strength INT
    db_1row {select crypt(:password, gen_salt('bf',:strength)) as password_hash}
    return $password_hash
}

proc qc::password_complexity_ok { args } {
    #| Return true if password meets min, max and minclasses complexity requirements
    #| Otherwise return false
    #| max size is limited to 72
    #| Usage: password_complexity_ok password min 2 max 10 minclasses 4
    qc::args $args password args
    qc::args2vars $args min max minclasses
        
    # Check min password length
    if { [info exists min] && [string length $password] < $min } {
        return false
    }
    # Check max password length
    if { [info exists max] && [string length $password] > $max } {
        return false
    }
    # Check password contains minimum number of character classes: upper, lower, digit, punctuation
    if { [info exists minclasses] } {
        foreach class [list upper lower digit] {
            if { [regexp "\[\[:${class}:\]\]" $password] } {
                incr classes
            }
        }
        # [[:punct:]] matches !"%&*()_-{}][@:#';?/.,\
        # Using inverse instead to catch £$^+=~><|`¬ in addition
        if {[regexp {[^[:upper:][:lower:][:digit:]]} $password]} {
            incr classes
        }
        if { $classes < $minclasses } {
            return false
        }
    }
    return true
}

proc qc::password_complexity_check { args } {
    #| Checks password against min, max and minclasses complexity requirements
    #| max size is limited to 72
    #| Usage: password_complexity_check password min 2 max 10 minclasses 4
    qc::args $args password args
    qc::args2vars $args min max minclasses

    default min 7
    default max 72
    default minclasses 1 
    
    # Check min password length
    if { ! [qc::password_complexity_ok $password min $min] } {
        error "Your password must be at least $min characters long" {} USER
    }
    # Check max password length
    if { ! [qc::password_complexity_ok $password max $max] } {
        error "Your password must be less than $max characters long" {} USER
    }
    # Check password contains minimum number of character classes: upper, lower, digit, punctuation
    if { ! [qc::password_complexity_ok $password minclasses $minclasses] } {
        error "Your password must contain at least $minclasses of uppercase, lowercase, numeric or punctuation" {} USER
    }
    return true
}
