package provide qcode 1.17
package require doc
namespace eval qc {}

proc qc::password_hash { password {strength 7} } {
    #| Returns a salted password hash using blowfish with an iteration count of $strength
    # Strength min is 4 and max is 31
    db_1row {select crypt(:password, gen_salt('bf',$strength)) as password_hash}
    return $password_hash
}

proc qc::password_complexity_check { args } {
    #| Checks password against min, max and minclass complexity requirements
    #| max size is limited to 72
    #| Usage: password_complexity_check password min 2 max 10 minclass 4
    qc::args $args password args
    qc::args2vars $args min max minclass

    default min 7
    default max 72
    default minclass 1 
    
    # Check password length and that confirm_password matches
    if { [string length $password] < $min } {
        error "Your password must be at least $min characters long" {} USER
    }
    if { [string length $password] > $max } {
        error "Your password must be less than $max characters long" {} USER
    }
    set classes 0
    foreach class [list upper lower digit] {
        set classes [expr {$classes + [regexp "\[\[:${class}:\]\]" $password]}]
    }
    # [[:punct:]] doesn't match the POSIX definition for the character class
    # Using the inverse of the above instead
    set classes [expr {$classes + [regexp {[^[:upper:][:lower:][:digit:]]} $password]}]
    if { $classes < $minclass } {
        error "Your password must contain at least $minclass of uppercase, lowercase, numeric or punctuation" {} USER
    }
    return true
}
