proc qc::is::email {email} {
    #| Checks if the given string follows the form of an email address.
    set pattern {^[-a-zA-Z0-9!$&*=^`|~#%'+/?_{}]+(\.[-a-zA-Z0-9!$&*=^`|~#%'+/?_{}]+)*}
    append pattern {@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$}
    return [regexp $pattern $email]
}
