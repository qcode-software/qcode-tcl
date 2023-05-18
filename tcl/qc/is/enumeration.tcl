proc qc::is::enumeration {enum_name value} {
    #| Checks if the given value is a value in enumeration enum_name.
    if {[qc::memoize qc::db_enum_exists $enum_name]
        && $value in [qc::memoize qc::db_enum_values $enum_name]} {
        return 1
    } else {
        return 0
    }
}
