proc qc::is::postcode {postcode} {
    #| Checks if the given string is a UK postcode.
    return [expr {[regexp \
                       {^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$} \
                       $postcode]
                  || [regexp {^BFPO ?[0-9]+$} $postcode]}]
}
