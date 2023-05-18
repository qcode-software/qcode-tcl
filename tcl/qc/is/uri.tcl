proc qc::is::uri {uri} {
    #| Test if the given uri is valid according to
    #| rfc3986 (https://tools.ietf.org/html/rfc3986)
    
    set unreserved {
        (?:[a-zA-Z0-9\-._~])
    }
    
    set sub_delims {
        (?:[!$&'()*+,;=])
    }
    
    set pct_encoded {
        (?:%[0-9a-fA-F]{2})
    }

    set pchar [subst -nocommands -nobackslashes {
        (?:${unreserved}|${pct_encoded}|${sub_delims}|[:@])
    }]
    
    set segment [subst -nocommands -nobackslashes {
        (?:${pchar}*)
    }]

    set segment_nz [subst -nocommands -nobackslashes {
        (?:${pchar}+)
    }]
    
    set segment_nz_nc [subst -nocommands -nobackslashes {
        (?:(?:${unreserved}|${pct_encoded}|${sub_delims}|[@])+)
    }]    

    set scheme {
        (?:[a-zA-Z][a-zA-Z+\-.]*)
    }

    set dec_octet {
        (?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])
    }
    
    set ipv4_address [subst -nocommands -nobackslashes {
        (?:${dec_octet}\.${dec_octet}\.${dec_octet}\.${dec_octet})
    }]

    set h16 {
        (?:[0-9a-fA-F]{1,4})
    }

    set ls32 [subst -nocommands -nobackslashes {
        (?:
         ${h16}:${h16}
         |
         ${ipv4_address}
         )
    }]

    set ipv6_address [subst -nocommands -nobackslashes {
        (?:
         (?:${h16}:){6}${ls32}
         |
         ::(?:${h16}:){5}${ls32}
         |
         (?:${h16})?::(?:${h16}:){4}${ls32}
         |
         (?:(?:${h16}:)?${h16})?::(?:${h16}:){3}${ls32}
         |
         (?:(?:${h16}:){0,2}${h16})?::(?:${h16}:){2}${ls32}
         |
         (?:(?:${h16}:){0,3}${h16})?::${h16}:${ls32}
         |
         (?:(?:${h16}:){0,4}${h16})?::${ls32}
         |
         (?:(?:${h16}:){0,5}${h16})?::${h16}
         |
         (?:(?:${h16}:){0,6}${h16})?::
         )
    }]

    set ipvfuture [subst -nocommands -nobackslashes {
        (?:v[0-9a-fA-F]+\.(?:${unreserved}|${sub_delims}|:)+)
    }]
    
    set ip_literal [subst -nocommands -nobackslashes {
        (?:\[(?:${ipv6_address}|${ipvfuture})\])
    }]
    
    set host [subst -nocommands -nobackslashes {
        (?:${ip_literal}
         |${ipv4_address}
         |(?:${unreserved}
           |${pct_encoded}
           |${sub_delims}
           )*
         )
    }]

    set user_info [subst -nocommands -nobackslashes {
        (?:(?:${unreserved}|${pct_encoded}|${sub_delims}|:)*)
    }]

    set port [subst -nocommands -nobackslashes {
        (?:[0-9]*)
    }]

    set authority [subst -nocommands -nobackslashes {
        (?:${user_info}@)?${host}(?::${port})?
    }]           

    set path_abempty [subst -nocommands -nobackslashes {
        (?:(?:/${segment})*)
    }]
    
    set path_absolute [subst -nocommands -nobackslashes {
        (?:/(?:${segment_nz}(?:/${segment})*)?)
    }]
    
    set path_noscheme [subst -nocommands -nobackslashes {
        (?:${segment_nz_nc}(?:/${segment})*)
    }]

    set path_rootless [subst -nocommands -nobackslashes {
        (?:${segment_nz}(?:/${segment})*)
    }]

    set path_empty [subst -nocommands -nobackslashes {
        (?:${pchar}{0})
    }]

    set fragment_char [subst -nobackslashes {
        (?:${pchar}|/|\?)
    }]

    set query_char [subst -nobackslashes {
        (?:${pchar}|/|\?)
    }]   

    set absolute_uri_re [subst -nocommands -nobackslashes {
        ^
        (?:
         ${scheme}:
         (?:(?://${authority}${path_abempty})
          |${path_absolute}
          |${path_rootless}
          |${path_empty}
          )
         (?:\?${query_char}*)?
         (?:\#${fragment_char}*)?
         )
        $
    }]
    
    set relative_uri_re1 [subst -nocommands -nobackslashes {
        ^
        (?:
         ${path_absolute}
         (?:\?${query_char}*)?
         (\#${fragment_char}*)?
         )
        $
    }]

    set relative_uri_re2 [subst -nocommands -nobackslashes {
        ^
        (?:
         ${path_noscheme}
         (?:\?${query_char}*)?
         (\#${fragment_char}*)?
         )
        $
    }]

    set relative_uri_re3 [subst -nocommands -nobackslashes {
        ^
        (?:
         ${path_empty}
         (?:\?${query_char}*)?
         (\#${fragment_char}*)?
         )
        $
    }]

    set relative_uri_re4 [subst -nocommands -nobackslashes {
        ^
        (?:
         //${authority}${path_abempty}
         (?:\?${query_char}*)?
         (\#${fragment_char}*)?
         )
        $
    }]      

    if {
        [regexp -expanded $absolute_uri_re $uri] 
        || [regexp -expanded $relative_uri_re1 $uri] 
        || [regexp -expanded $relative_uri_re2 $uri]
        || [regexp -expanded $relative_uri_re3 $uri]
        || [regexp -expanded $relative_uri_re4 $uri] 
    } {
        return 1
    } else {
        return 0
    }
}
