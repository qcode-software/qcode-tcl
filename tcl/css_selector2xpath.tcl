namespace eval qc {
    namespace export css_selector2xpath
}

proc qc::css_selector2xpath {selector {xpath ""}} {
    #| Convert a css selector to an XPath
    # (Errors on pseudo-elements and dynamic pseudo-classes such as :hover)
    # (Also does not support any of the x-of-type pseudo-classes unless combined with an explicit element type)

    # A css selector consists of one or more "simple selector sequences", separated by "combinators"
    # This maps almost exactly to XPath, which consists of one or more "Steps".

    set combinator " "
    set sequence_combinator_list [list]
    while { $selector ne "" } {
        switch $combinator {
            " " { append xpath {//} }
            > { append xpath {/} }
            ~ { append xpath {/following-sibling::} }
            + { append xpath {/following-sibling::*[1]/self::} }
        }

        # Shift next simple selector sequence from the selector string
        set depth 0
        set sequence ""
        for {set i 0} {$i < [string length $selector]} {incr i} {
            switch [string index $selector $i] {
                \( - \[ {incr depth}
                \) - \] {incr depth -1}
                " " - > - ~ - + {
                    if { $depth == 0 } {
                        break
                    }
                }
            }
            append sequence [string index $selector $i]               
        }
        if { $depth > 0 } {
            error "Unable to parse selector $selector - unclosed parentheses"
        }
        set selector [string range $selector $i end]

        append xpath [qc::css_simple_selector_sequence2xpath $sequence]

        if { $selector ne "" } {
            # Shift next combinator from selector string
            if { ! [regexp {^\s*([\s>+~])\s*(.+?)$} $selector -> combinator remainder] } {
                error "Unable to parse combinator / sequence from selector string $selector"
            }
            set selector $remainder
        }
    }
    return $xpath
}

proc qc::css_simple_selector_sequence2xpath {sequence} {
    #| Convert a css simple selector sequence to an XPath node test + predicate

    set xpath ""
    # Shift type selector from simple selector sequence
    if { [regexp {^([^\[:.\#]+)(.*?)$} $sequence -> element_type remainder] } {
        set sequence $remainder
    } else {
        set element_type "*"
    }

    # Css type and universal selectors have the same syntax as XPath node tests
    if { [regexp {[^a-zA-Z0-9*]} $element_type] } {
        error "Unable to parse $sequence - Invalid element type"
    }
    append xpath $element_type

    while { $sequence ne "" } {
        # Shift next simple selector from simple selector sequence
        set simple_selector [string index $sequence 0]
        set depth 0
        set end false
        for {set i 1} {$i < [string length $sequence]} {incr i} {
            switch [string index $sequence $i] {
                \( { incr depth }
                \) { incr depth -1 }
                \[ -
                : -
                . -
                \# {
                    if { $depth == 0 } {
                        break
                    }
                }
            }
            append simple_selector [string index $sequence $i]
        }
        if { $depth > 0 } {
            error "Unable to parse $sequence - unclosed parentheses"
        }
        set sequence [string range $sequence $i end]

        set predicate [qc::css_simple_selector2xpath $simple_selector $element_type]
        append xpath "\[$predicate\]"
    }
    return $xpath
}

proc qc::css_simple_selector2xpath {simple_selector {element_type *}} {
    #| Convert a css simple selector (but not a type or universal selector) to an XPath predicate
    switch [string index $simple_selector 0] {
        . { # class selector
            set class [string range $simple_selector 1 end]
            return "contains(concat(' ',normalize-space(@class),' '),[qc::xpath_literal " $class "])"
        }
        \# { # id selector
            set id [string range $simple_selector 1 end]
            return "@id=[qc::xpath_literal $id]"
        }
        : { # pseudo-class
            set pseudo_class [string range $simple_selector 1 end]
            return [qc::css_pseudo_class2xpath $pseudo_class $element_type]
        }
        \[ { #attribute selector
            if { [string index $simple_selector end] ne "\]" } {
                error "Unable to parse $simple_selector"
            }
            set attribute_selector [string range $simple_selector 1 end-1]
            return [qc::css_attribute_selector2xpath $attribute_selector]
        }
    }
}

proc qc::css_attribute_selector2xpath {attribute_selector} {
    #| Convert a css attribute selector to an XPath expression
    if { ! [regexp {^([-a-zA-Z0-9_]+)(?:([~|^$*]?=)"(.*)")?$} $attribute_selector -> attribute test value] } {
        error "Unable to parse $attribute_selector"
    }
    switch $test {
        "" {
            # Element has the attribute
            return "@$attribute"
        }
        = {
            # Element has attribute, exactly equal to value
            return "@${attribute}=[qc::xpath_literal $value]"
        }
        ~= {
            # Treat the attribute value as a space-separated list of words,
            # test whether $value is one of those words
            if { $value eq "" || [string first " " $value] != -1 } {
                return "false()"
            } else {
                return "contains(concat(' ',normalize-space(@${attribute}),' '),[qc::xpath_literal " ${value} "])"
            }
        }
        |= {
            # Attribute is hyphen separated list of values starting with $value
            return "@${attribute}=[qc::xpath_literal $value] or starts-with(@${attribute},[qc::xpath_literal "${value}-"])"
        }
        ^= {
            # Attribute starts with $value
            if { $value eq "" } {
                return "false()"
            } else {
                return "starts-with(@${attribute},[qc::xpath_literal $value])"
            }
        }
        $= {
            # Attribute ends with $value
            if { $value eq "" } {
                return "false()"
            } else {
                return "substring(@${attribute},string-length(@${attribute}) - string-length([qc::xpath_literal $value])) = [qc::xpath_literal $value]"
            }
        }
        *= {
            # Attribute contains substring $value
            if { $value eq "" || [string first " " $value] != -1 } {
                return "false()"
            } else {
                return "contains(@${attribute},[qc::xpath_literal $value])"
            }
        }
        default {
            error "Unknown attribute selector $attribute_selector"
        }
    }
}

proc qc::css_pseudo_class2xpath {pseudo_class {element_type *}} {
    #| Convert a css pseudo-class selector to an XPath expression
    if { [string index $pseudo_class 1] eq ":" } {
        error "Unable to convert pseudo-element :$pseudo_class to xpath"
    }
    # Many pseudo-classes allow optional arguments (eg. :nth-child(2) ).
    if { ! [regexp {^([-a-z]+)(?:\((.+)\))?$} $pseudo_class -> function argument] } {
        error "Unable to parse pseudo-class $pseudo_class"
    }
    if { $function in {nth-child nth-last-child nth-of-type nth-last-of-type lang not} } {
        if { $argument eq "" } {
            error "Pseudo class $function requires an argument"
        }
    } else {
        if { $argument ne "" } {
            error "Pseduo-class $function does not accept arguments"
        }
    }
    switch $function {
        root {
            return "count(ancestor::*)=0"
        }
        nth-child {
            return [qc::nth_term $argument "(count(preceding-sibling::*) + 1)"]
        }
        nth-last-child {
            return [qc::nth_term $argument "(count(following-sibling::*) + 1)"]
        }
        first-child {
            return {count(preceding-sibling::*) = 0}
        }
        last-child {
            return {count(following-sibling::*) = 0}
        }
        only-child {
            return {last()=1}
        }
        empty {
            return {count(*)=0}
        }
        lang {
            return "lang([qc::xpath_literal $argument])"
        }
        enabled {
            return {not(@disabled)}
        }
        disabled {
            return {@disabled}
        }
        checked {
            return {@checked}
        }
        not {
            if { [regexp {[:.#\[]} [string range $argument 1 end]] } {
                error "Error parsing pseudo-class $pseudo_class"
            }
            if { [string index $argument 0] in {\# . : \[} } {
                if { [regexp {^:not\(.*\)$}] } {
                    error "Nested negation not permitted by css specs"
                }
                return "not([qc::css_simple_selector2xpath $argument])"
            } {
                if { regexp {[^a-zA-Z0-9*]} $element_type } {
                    error "Error parsing pseudo-class $pseudo_class"
                }
                return "not($agument)"
            }
        }
        only-of-type {
            if { $element_type eq "*" } {
                error "x-of-type psuedo-classes not supported without explicit type"
            }
            return "count(preceding-sibling::${element_type}) + count(following-sibling::${element_type}) = 0"
        }
        nth-of-type {
            if { $element_type eq "*" } {
                error "x-of-type psuedo-classes not supported without explicit type"
            }
            return [nth_term $argument "(count(preceding-sibling::${element_type}) + 1)"]
        }
        nth-last-of-type {
            if { $element_type eq "*" } {
                error "x-of-type psuedo-classes not supported without explicit type"
            }
            return [nth_term $argument "(count(following-sibling::${element_type}) + 1)"]
        }
        first-of-type {
            if { $element_type eq "*" } {
                error "x-of-type psuedo-classes not supported without explicit type"
            }
            return "count(preceding-sibling::${element_type}) = 0"
        }
        last-of-type {
            if { $element_type eq "*" } {
                error "x-of-type psuedo-classes not supported without explicit type"
            }
            return "count(following-sibling::${element_type}) = 0"
        }

        link -
        visited -
        active -
        hover -
        focus -
        target {
            error "Unable to parse dynamic pseudo-class $function to xpath"
        }
        first-line -
        first-letter -
        before -
        after {
            error "Unable to convert pseudo-element $function to xpath"
        }
    }
}

proc qc::nth_term {expression n} {
    #| Given an XPath expression $n returning the position of the current node in some context,
    # and an expression in the form used by :nth-child in the css3 selector specs,
    # return a matching XPath expression.
    if { [regexp {^\s*([0-9]+)\s*$} $expression -> b] } {
        set a 0
    } else {
        if { ! [regexp {^\s*(?:([-+]?[0-9]+)[nN])?\s*([-+]\s*[0-9]+)?\s*$} $expression -> a b] } {
            if { ! [regexp -nocase {^\s*(odd|even)\s*$} $expression -> keyword] } {
                error "Unable to parse nth-term \"$expression\""
            }
            switch $keyword {
                odd {set a 2; set b 1}
                even {set a 2; set b 0}
            }
        }
    }
    if { $a eq "" && $b eq "" } {
        error "Unable to parse nth-term \"$expression\""
    }
    if { $a eq "" } {
        set a 0
    }
    if { $b eq "" } {
        set b 0
    }
    set b [string map {" " ""} $b]
    set a [string trimleft $a +]
    set b [string trimleft $b +]
    if { $a == 0 } {
        return "$n = $b"
    } elseif { $a > 0 } {
        set mod [expr {$b % $a}]
        if { $b > 0 } {
            return "$n >= $b and ($n mod $a) = $mod"
        } else {
            return "($n mod $a) = $mod"
        }
    } else {
        set mod [expr {$b % - $a}]
        if { $b >= 0 } {
            return "($n <= $b) and ($n mod $a) = $mod"
        } else {
            return "false()"
        }
    }
}

proc qc::xpath_literal {string} {
    if { [string first ' $string] == -1 } {
        return "'$string'"
    }
    if { [string first \" $string] == -1 } {
        return "\"$string\""
    }
    return "concat('[join [split $string '] {',"'",'}]')"
}