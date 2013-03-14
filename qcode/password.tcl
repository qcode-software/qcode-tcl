package provide qcode 1.17
package require doc
namespace eval qc {}

proc qc::password_hash { password {strength 7} } {
    #| Returns a salted password hash using blowfish with an iteration count of $strength
    # Strength min is 4 and max is 31
    check strength INT
    db_1row {select crypt(:password, gen_salt('bf',:strength)) as password_hash}
    return $password_hash
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
    
    # Check password length and that confirm_password matches
    if { [string length $password] < $min } {
        error "Your password must be at least $min characters long" {} USER
    }
    if { [string length $password] > $max } {
        error "Your password must be less than $max characters long" {} USER
    }
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
        error "Your password must contain at least $minclasses of uppercase, lowercase, numeric or punctuation" {} USER
    }
    return true
}
