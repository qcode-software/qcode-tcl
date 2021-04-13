namespace eval qc {
    namespace export mime_type_guess
}

set qc::mime_mappings {
    ".adp" "text/html"
    ".ai" "application/postscript"
    ".aif" "audio/aiff"
    ".aifc" "audio/aiff"
    ".aiff" "audio/aiff"
    ".ani" "application/x-navi-animation"
    ".art" "image/x-art"
    ".asc" "text/plain"
    ".au" "audio/basic"
    ".avi" "video/x-msvideo"
    ".bcpio" "application/x-bcpio"
    ".bin" "application/octet-stream"
    ".bmp" "image/bmp"
    ".cdf" "application/x-netcdf"
    ".cgm" "image/cgm"
    ".class" "application/octet-stream"
    ".cpio" "application/x-cpio"
    ".cpt" "application/mac-compactpro"
    ".css" "text/css"
    ".csv" "application/csv"
    ".dci" "text/html"
    ".dcr" "application/x-director"
    ".der" "application/x-x509-ca-cert"
    ".dir" "application/x-director"
    ".dll" "application/octet-stream"
    ".dms" "application/octet-stream"
    ".doc" "application/msword"
    ".docx" "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ".dp" "application/commonground"
    ".dvi" "applications/x-dvi"
    ".dwf" "drawing/dwf"
    ".dwg" "image/vnd.dwg"
    ".dxf" "image/vnd.dxf"
    ".dxr" "application/x-director"
    ".elm" "text/plain"
    ".eml" "message/rfc822"
    ".etx" "text/x-setext"
    ".exe" "application/octet-stream"
    ".ez" "application/andrew-inset"
    ".fm" "application/vnd.framemaker"
    ".gbt" "text/plain"
    ".gif" "image/gif"
    ".gtar" "application/x-gtar"
    ".gz" "application/x-gzip"
    ".hdf" "application/x-hdf"
    ".htm" "text/html"
    ".html" "text/html"
    ".hpgl" "application/vnd.hp-hpgl"
    ".hqx" "application/mac-binhex40"
    ".ice" "x-conference/x-cooltalk"
    ".ief" "image/ief"
    ".ies" "application/octet-stream"
    ".igs" "image/iges"
    ".iges" "image/iges"
    ".jfif" "image/jpeg"
    ".jpe" "/image/jpeg"
    ".jpg" "image/jpeg"
    ".jpeg" "/image/jpeg"
    ".js" "application/x-javascript"
    ".kar" "audio/midi"
    ".latex" "application/x-latex"
    ".ldt" "application/octet-stream"
    ".lha" "application/octet-stream"
    ".ls" "application/x-javascript"
    ".lxc" "application/vnd.ms-excel"
    ".lzh" "application/octet-stream"
    ".man" "application/x-troff-man"
    ".map" "application/x-navimap"
    ".me" "application/x-troff-me"
    ".mesh" "model/mesh"
    ".mid" "audio/x-midi"
    ".midi" "audio/x-midi"
    ".mif" "application/vnd.mif"
    ".mocha" "application/x-javascript"
    ".mov" "video/quicktime"
    ".movie" "video/x-sgi-movie"
    ".mp2" "audio/mpeg"
    ".mp3" "audio/mpeg"
    ".mpe" "video/mpeg"
    ".mpeg" "video/mpeg"
    ".mpg" "video/mpeg"
    ".mpga" "audio/mpeg"
    ".ms" "application/x-troff-ms"
    ".msh" "model/mesh"
    ".nc" "application/x-netcdf"
    ".nvd" "application/x-navidoc"
    ".nvm" "application/x-navimap"
    ".oda" "application/oda"
    ".pbm" "image/x-portable-bitmap"
    ".pcl" "application/vnd.hp-pcl"
    ".pclx" "application/vnd.hp-pclx"
    ".pdb" "chemical/x-pdb"
    ".pdf" "application/pdf"
    ".pgm" "image/x-portable-graymap"
    ".pgn" "application/x-chess-pgn"
    ".pic" "image/pict"
    ".pict" "image/pict"
    ".pnm" "image/x-portable-anymap"
    ".png" "image/png"
    ".pot" "application/vnd.ms-powerpoint"
    ".ppm" "image/x-portable-pixmap"
    ".pps" "application/vnd.ms-powerpoint"
    ".ppt" "application/vnd.ms-powerpoint"
    ".ps" "application/postscript"
    ".qt" "video/quicktime"
    ".ra" "audio/x-realaudio"
    ".ram" "audio/x-pn-realaudio"
    ".rar" "application/x-rar-compressed"
    ".ras" "image/x-cmu-raster"
    ".rgb" "image/x-rgb"
    ".rm" "audio/x-pn-realaudio"
    ".roff" "application/x-troff"
    ".rpm" "audio/x-pn-realaudio-plugin"
    ".rtf" "application/rtf"
    ".rtx" "text/richtext"
    ".sda" "application/vnd.stardivision.draw"
    ".sdc" "application/vnd.stardivision.calc"
    ".sdd" "application/vnd.stardivision.impress"
    ".sdp" "application/vnd.stardivision.impress"
    ".sdw" "application/vnd.stardivision.writer"
    ".sgl" "application/vnd.stardivision.writer-global"
    ".sgm" "text/sgm"
    ".sgml" "text/sgml"
    ".sh" "application/x-sh"
    ".shar" "application/x-shar"
    ".sht" "text/html"
    ".shtml" "/text/html"
    ".silo" "model/mesh"
    ".sit" "application/x-stuffit"
    ".skd" "application/vnd.stardivision.math"
    ".skm" "application/vnd.stardivision.math"
    ".skp" "application/vnd.stardivision.math"
    ".skt" "application/vnd.stardivision.math"
    ".smf" "application/vnd.stardivision.math"
    ".smi" "application/smil"
    ".smil" "application/smil"
    ".snd" "audio/basic"
    ".spl" "application/x-futuresplash"
    ".sql" "application/x-sql"
    ".src" "application/x-wais-source"
    ".stc" "application/vnd.sun.xml.calc.template"
    ".std" "application/vnd.sun.xml.draw.template"
    ".sti" "application/vnd.sun.xml.impress.template"
    ".stl" "application/x-navistyle"
    ".stw" "application/vnd.sun.xml.writer.template"
    ".svg" "image/svg+xml"
    ".swf" "application/x-shockwave-flash"
    ".sxc" "application/vnd.sun.xml.calc"
    ".sxd" "application/vnd.sun.xml.draw"
    ".sxg" "application/vnd.sun.xml.writer.global"
    ".sxl" "application/vnd.sun.xml.impress"
    ".sxm" "application/vnd.sun.xml.math"
    ".sxw" "application/vnd.sun.xml.writer"
    ".t" "application/x-troff"
    ".tar" "application/x-tar"
    ".tcl" "x-tcl"
    ".tex" "application/x-tex"
    ".texi" "application/x-texinfo"
    ".texinfo" "application/x-texinfo"
    ".text" "text/plain"
    ".tgz" "application/x-gtar"
    ".tif" "image/tiff"
    ".tiff" "image/tiff"
    ".tr" "application/x-troff"
    ".tsv" "text/tab-separated-values"
    ".txt" "text/plain"
    ".ustar" "application/x-ustar"
    ".vcd" "application/x-cdlink"
    ".vor" "application/vnd.stardivision.writer"
    ".vrml" "model/vrml"
    ".wav" "audio/x-wav"
    ".wbmp" "image/vnd.wap.wbmp"
    ".webp" "image/webp"
    ".wkb" "application/vnd.ms-excel"
    ".wks" "application/vnd.ms-excel"
    ".wml" "text/vnd.wap.wml"
    ".wmlc" "application/vnd.wap.wmlc"
    ".wmls" "text/vnd.wap.wmlscript"
    ".wmlsc" "application/vnd.wap.wmlscript"
    ".wrl" "model/vrml"
    ".xbm" "image/x-xbitmap"
    ".xls" "application/vnd.ms-excel"
    ".xlsx" "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ".xlw" "application/vnd.ms-excel"
    ".xpm" "image/x-xpixmap"
    ".xht" "application/xhtml+xml"
    ".xhtml" "application/xhtml+xml"
    ".xml" "text/xml"
    ".xsl" "text/xml"
    ".xyz" "chemical/x-pdb"
    ".xwd" "image/x-xwindowdump"
    ".z" "application/x-compress"
    ".zip" "application/zip"
}

proc qc::mime_type_guess { filename } {
    #| Lookup a mimetype based on a file extension. Case insensitive.
    # Based on ns_guesstype.
    # Defaults to "*/*".    
    set default_type "*/*"
    set ext [file extension [string tolower $filename]]
    if { [dict exists $qc::mime_mappings $ext] } {
        return [dict get $qc::mime_mappings $ext]
    }
    return $default_type
}

proc qc::mime_has_unique_file_extension { mime_type } {
    #| Check if mime_type maps to a unique file extension
    set mime_types [dict values $qc::mime_mappings]
    set first_index [lsearch -exact $mime_types $mime_type]
    if { $first_index == -1 } {
        # No mapping for mime_type to file extension
        return false
    }
    set second_index [lsearch \
                          -exact \
                          -start ${first_index}+1 \
                          $mime_types \
                          $mime_type]
    if { $second_index == -1 } {
        # Multiple (non-unique) mappings for mime_type to
        # file extension
        return true
    }
    return false
}

proc qc::mime_file_extension { mime_type } {
    #| Look up a file extension based on a mime_type
    return [dict get [lreverse $qc::mime_mappings] $mime_type]
}
