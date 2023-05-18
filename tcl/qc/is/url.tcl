proc qc::is::url {args} {
    #| Checks if the given string is a URL.
    #| This is a more restrictive subset of all legal uri's defined by RFC 3986
    #| Relax as needed
    qc::args $args -relative -- url
    qc::default relative false
    if { $relative } {
        return [regexp -expanded {
            # path
            ^([a-zA-Z0-9_\-\.~+/%&]+)?
            # query
            (\?[a-zA-Z0-9_\-\.~+/%=&:@]+)?
            # anchor
            (\#[a-zA-Z0-9_\-\.~+/%]+)?
            $
        } $url]
    } else {
        return [regexp -expanded {
            # protocol
            ^https?://
            # domain
            [a-z0-9\-\.]+
            # port
            (:[0-9]+)?
            # path
            ([a-zA-Z0-9_\-\.~+/%&]+)?
            # query
            (\?[a-zA-Z0-9_\-\.~+/%=&:@]+)?
            # anchor
            (\#[a-zA-Z0-9_\-\.~+/%]+)?
            $
        } $url]
    }
}

proc qc::is::url_path {string} {
    #| Checks if the given string is an url path.
    return [regexp {/([a-zA-Z0-9\-._~]|%[0-9a-fA-F]{2}|[!$&'()*+,;=:@]|/)*$} $string]
}
