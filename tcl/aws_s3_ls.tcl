namespace eval qc::aws {
    namespace export s3
    namespace ensemble create
}
namespace eval qc::aws::s3 {
    namespace export ls
    namespace ensemble create

    proc ls { args } {
        #| Lists the contents of a bucket optionally filtered by objects 
        #| starting with object_key_prefix
        #| Usage: qc::aws s3 ls mybucket ?prefix?
        qc::args $args -max_keys 1000 -- bucket {object_key_prefix ""}

        set query_params [dict create \
                            max-keys $max_keys \
                            prefix $object_key_prefix \
                         ]
        set s3_uri [qc::cast s3_uri $bucket]
        set response [qc::aws s3 rest_api http_get $s3_uri $query_params]
        return [qc::aws s3 xml2ldict $response {/ns:ListBucketResult/ns:Contents}]
    }
}
