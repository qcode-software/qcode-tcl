proc qc::is::s3_bucket {s3_bucket} {
    #| Checks if the given string is a valid s3 bucket
    #| Rules from:
    #| https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
    
    # Bucket names must be between 3 and 63 characters long
    if { [string length $s3_bucket] < 3 ||
         [string length $s3_bucket] > 63 } {
        return 0
    }

    # Bucket names can consist only of lowercase letters, numbers, dots (.),
    # and hyphens (-)
    if { [regexp {[^a-z0-9.-]} $s3_bucket] } {
        return 0
    }

    # Bucket names must begin and end with a letter or number.
    if { [regexp {[^a-z0-9]} [string index $s3_bucket 0]] ||
         [regexp {[^a-z0-9]} [string index $s3_bucket end]] } {
        return 0
    }

    # Bucket names must not be formatted as an IP address (for example, 192.168.5.4).
    if { [qc::is ip $s3_bucket] } {
        return 0
    }

    return 1
}

proc qc::is::s3_object_key {s3_object_key} {
    #| Checks if the given string is a valid s3 object key
    #| Limits characters to those defined as safe:
    #| https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html#object-keys

    # Restrict to safe characters (excluding the starting "/")
    if { [regexp {[^-a-zA-Z0-9/!_.*'()]} $s3_object_key] } {
        return 0
    }

    # Object keys ending in "." can cause issues
    if { [string index $s3_object_key end] eq "." } {
        return 0
    }

    return 1
}

proc qc::is::s3_uri {s3_uri} {
    #| Checks if the given string is a valid s3 URI
    # Valid Examples:
    # s3://bucket/location.png
    # S3://test/location/foo/bar
    # s3://bucket

    # Check for protocol 
    if { ![regexp {^[sS]3://} $s3_uri]} {
        return 0
    }

    # Check the bucket and key are valid
    lassign [qc::s3 uri_bucket_object_key $s3_uri] bucket object_key
    if { ![qc::is s3_bucket $bucket] } {
        return 0
    }
    if { $object_key ne "" && ![qc::is s3_object_key $object_key] } {
        return 0
    }
    
    return 1
}
