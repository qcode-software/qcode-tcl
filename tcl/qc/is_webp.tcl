proc qc::is_webp {file} {
    #| Deprecated - see qc::is webp
    #| Check if the file is a webp image.

    return [qc::is webp $file]
}
