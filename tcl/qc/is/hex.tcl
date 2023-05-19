proc qc::is::hex {string} {
    #| Checks if the given string is a hex number.
    return [regexp -nocase {^[0-9a-f]*$} $string]
}
