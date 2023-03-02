namespace eval qc::aws {
    namespace export s3
    namespace ensemble create
}

namespace eval qc::aws::s3 {
    namespace export s3_uri_parse
    namespace ensemble create

    proc s3_uri_parse { s3_uri } {
        #| Parse s3 uri to extract bucket and object key into a dict
       
        if { [qc::is s3_uri $s3_uri] } {
            regexp {^(?:[sS]3://|/)?([^/]+)/?(.*)} $s3_uri -> bucket object_key
        } {
            error "Unable to parse s3 uri, \"$s3_uri\""
        }
        return [qc::dict_from bucket object_key]
    }
}
