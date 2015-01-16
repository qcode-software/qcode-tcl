namespace eval qc::castable {
    
    namespace export integer bigint smallint decimal boolean timestamp timestamptz char varchar enumeration text domain safe_html safe_markdown date postcode creditcard period
    namespace ensemble create -unknown {
        data_type_parser
    }

    proc integer {string} {
        #| Test if the given string can be cast to an integer.
        try {
            qc::cast integer $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc bigint {string} {
        #| Test if the given string can be cast to a big integer.
        try {
            qc::cast bigint $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc smallint {string} {
        #| Test if the given string can be cast to a small integer.
        try {
            qc::cast smallint $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc decimal {args} {
        #| Test if the given value can be cast to a decimal.
        try {
            qc::cast decimal {*}$args
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc boolean { string {true t} {false f} } {
        #| Test if the given string can be cast to an boolean.
        try {
            qc::cast boolean $string
            return true
        } on error [list error_message options] {
            return false
        }        
    }

    proc timestamp {string} {
        #| Test if the given string can be cast to a timestamp without timezone.
        try {
            qc::cast timestamp $string
            return true
        } on error [list error_message options] {
            return false
        }        
    }

    proc timestamptz {string} {
        #| Test if the given string can be cast to an timestamp with timezone.
        try {
            qc::cast timestamptz $string
            return true
        } on error [list error_message options] {
            return false
        }        
    }

    proc char {length string} {
        #| Test if the given string can be cast to a fixed length string.
        try {
            qc::cast char $length $string
            return true
        } on error [list error_message options] {
            return false
        }        
    }

    proc varchar {length string} {
        #| Test if the given string can be cast to a varchar of given length.
        try {
            qc::cast varchar $length $string
            return true
        } on error [list error_message options] {
            return false
        }        
    }

    proc enumeration {name value} {
        #| Test if the given value can be cast to an enumeration value in $name.
        try {
            qc::cast enumeration $name $value
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc text {string} {
        #| Test if the given string can be cast to text.
        try {
            qc::cast text $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc domain {domain_name value} {
        #| Test if the given value can be cast to domain $domain_name.
        try {
            qc::cast domain $domain_name $value
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc safe_html {text} {
        #| Test if the given text can be cast to safe html.
        return [qc::is safe_html $text]
    }

    proc safe_markdown {text} {
        #| Test if the given text can be cast to safe markdown.
        return [qc::is safe_markdown $text]
    }

    proc date {string} {
        #| Test if the given string can be cast to a date.
        try {
            qc::cast date $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc postcode {string} {
        #| Test if the given string can be cast to a UK postcode.
        try {
            qc::cast postcode $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc creditcard {string} {
        #| Test if the given string can be cast to a credit card number.
        try {
            qc::cast creditcard $string
            return true
        } on error [list error_message options] {
            return false
        }
    }

    proc period {string} {
        #| Test if the given string can be cast to a period.
        try {
            qc::cast period $string
            return true
        } on error [list error_message options] {
            return false
        }
    }
}