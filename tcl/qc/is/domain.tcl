proc qc::is::domain {domain_name value} {
    #| Checks if the given value falls under the domain domain_name.
    if {[qc::memoize qc::db_domain_exists $domain_name]} {
        set base_type [qc::memoize qc::db_domain_base_type $domain_name]
        if { ! [qc::is $base_type $value] } {
            return 0
        }
        set constraints [qc::memoize qc::db_domain_constraints $domain_name]
        dict for {constraint_name check_clause} $constraints {
            if { ! [qc::db_eval_domain_constraint $value $base_type $check_clause] } {
                return 0
            }
        }
        return 1
    }
    return 0
}
