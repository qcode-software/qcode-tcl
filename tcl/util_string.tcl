namespace eval qc {
    namespace export upper lower trim truncate plural singular cmplen levenshtein_distance string_similarity strip_common_leading_whitespace
}

proc qc::upper { string } {
    #| Convert string to upper case
    return [string toupper $string]
}

proc qc::lower { string } {
    #| Convert string to lower case
    return [string tolower $string]
}

proc qc::trim { string } {
    #| Removes and leading or trailing white space.
    return [string trim $string]
}

proc qc::truncate {string length} {
    #| Truncate to nearest word boundary to create string of at the most of specified length
    if { [string length $string]<= $length } {
	return $string
    }
    set position [string wordstart $string $length]
    if { $position == 0 } {
	set position $length
    }
    return [string range $string 0 [expr {$position-1}]]
}

# We'll begin with a box, and the plural is boxes;
# but the plural of ox became oxen not oxes.
# One fowl is a goose, but two are called geese,
# yet the plural of moose should never be meese.
# You may find a lone mouse or a nest full of mice;
# yet the plural of house is houses, not hice.
# If the plural of man is always called men,
# why shouldn't the plural of pan be called pen?
# If I spoke of my foot and show you my feet,
# and I give you a boot, would a pair be called beet?
# If one is a tooth and a whole set are teeth,
# why shouldn't the plural of booth be called beeth?
# Then one may be that, and three would be those,
# yet hat in the plural would never be hose,
# and the plural of cat is cats, not cose.
# We speak of a brother and also of brethren,
# but though we say mother, we never say methren.
# Then the masculine pronouns are he, his and him,
# but imagine the feminine, she, shis and shim.

proc qc::plural word {
    #| Attempts to return the plural form of a word.
    #| Assumes the supplied word is not already plural.
    set exceptions {
	man men
	person people
	goose geese
	mouse mice
	nucleus nuclei
	syllabus syllabi
	focus foci
	fungus fungi
	cactus cacti
	phenomenon phenomena
	criterion criteria
	foot feet
        louse lice
	ox oxen
	tooth teeth
	genus genera
        phylum phyla
        radius radii
        cherub cherubim
        mythos mythoi
        formula formulae
	radio radios
	flex flexes
    }
    if { [dict exists $exceptions $word] } {
	return [dict get $exceptions $word]
    }

    if { [in {calf elf half hoof leaf loaf scarf self sheaf thief wolf} $word] } {
	return [string range $word 0 end-1]ves
    }
    if { [in {knife life wife} $word] } {
	return [string range $word 0 end-2]ves
    }
    if { [in {auto kangaroo kilo memo photo piano pimento pro solo soprano studio tattoo video zoo} $word] } {
	return ${word}s
    }
    # unchanged
    if { [in {cod deer fish perch sheep trout species barracks equipment conduit glasses} $word] } {
	return $word
    }

    switch -regexp -- $word {
	{ing$} - {ies$}           {return $word}
	{[ei]x$}                  {return [string range $word 0 end-2]ices}
	{[sc]h$} - {[soxz]$}      {return ${word}es}
	{[bcdfghjklmnprstvwxz]y$} {return [string range $word 0 end-1]ies}
	{child$}                  {return ${word}ren}
	{eau$}                    {return ${word}x}
	{is$}                     {return [string range $word 0 end-2]es}
	{woman$}                  {return [string range $word 0 end-2]en}

    }
    return ${word}s
}

proc qc::singular word {
    # TODO unused
    switch -- $word {
	men   {return man}
	feet  {return foot}
	geese {return goose}
	lice {return louse}
	mice {return mouse}
	oxen    {return ox}
	teeth {return tooth}
	calves - elves - halves - hooves - leaves - loaves - scarves
	- selves - sheaves - thieves - wolves
	{return [string range $word 0 end-3]f}
	knives - lives - wives
	{return [string range $word 0 end-3]fe}
	autos - kangaroos - kilos - memos
	- photos - pianos - pimentos - pros - solos - sopranos - studios
	- tattoos - videos - zoos
	{return [string range $word 0 end-1]}
	cod - deer - fish - offspring - perch - sheep - trout
	- species
	{return $word}
	genera {return genus}
	phyla {return phylum}
	radii {return radius}
	cherubim {return cherub}
	mythoi {return mythos}
	phenomena {return phenomenon}
	formulae {return formula}
	octopodes {return octopus}
	octopi {return octopus}
    }
    switch -regexp -- $word {
	{[ei]ices$}                  {return [string range $word 0 end-4]x}
	{[sc]hes$} - {[soxz]es$}      {return [string range $word 0 end-2]}
	{[bcdfghjklmnprstvwxz]ies$} {return [string range $word 0 end-3]y}
	{children$}                  {return [string range $word 0 end-3]}
	{eaux$}                    {return [string range $word 0 end-1]}
	{ises$}                     {return [string range $word 0 end-4]is}
	{women$}                  {return [string range $word 0 end-2]an}
	{s$}                       {return [string range $word 0 end-1]}
    }
    #Not handled
    error "Don't know singular for \"$word\""
}

proc qc::cmplen {string1 string2} {
    #| Compare length of 2 strings
    if { [string length $string1]<[string length $string2] } {
	return -1 
    } elseif {[string length $string1]==[string length $string2] } {
	return 0
    } else {
	return 1
    }
}

proc qc::levenshtein_distance {s t} {
    # Returns the number of edits required to turn one string into the other.
    # Tcl wiki 
    if {![set n [string length $t]]} {
        return [string length $s]
    } elseif {![set m [string length $s]]} {
        return $n
    }
    for {set i 0} {$i <= $m} {incr i} {
        lappend d 0
        lappend p $i
    }
    for {set j 0} {$j < $n} {} {
        set tj [string index $t $j]
        lset d 0 [incr j]
        for {set i 0} {$i < $m} {} {
            set a [expr {[lindex $d $i]+1}]
            set b [expr {[lindex $p $i]+([string index $s $i] ne $tj)}]
            set c [expr {[lindex $p [incr i]]+1}]
            lset d $i [expr {$a<$b ? $c<$a ? $c : $a : $c<$b ? $c : $b}]
        }
        set nd $p; set p $d; set d $nd
    }
    return [lindex $p end]
}

proc qc::string_similarity {s t} {
    #| Returns a number from 0 to 1 indicating how similar the 2 strings are
    #| using the levenshtein distance.
    # Tcl wiki

    set sl [string length $s]
    set tl [string length $t]

    set ml [max $sl $tl]
    set dn [qc::levenshtein_distance $s $t]

    # -- get match characters number
    set mn [expr $ml - $dn]

    # -- match number != 0? (mn-1)/tl + (1/tl)*(mn/sl)
    return [expr $mn==0?0:($mn-1+double($mn)/$sl)/$tl]
}

proc qc::strip_common_leading_whitespace {text} {
    #| Strip leading whitespace common to all non-zero length lines
    #
    # replace tabs with four spaces
    regsub -all {\t} $text "    " text
    regsub -all {\r\n} $text \n text
    foreach line [split $text \n] {
        if { [regexp {^( *)[^ ]} $line -> whitespace] } {
            set length [string length $whitespace]
            if { ![info exists min] || $length<$min} {
                set min $length
            } 
        }
    }
    if { [info exists min] && $min>0 } {
        regsub -all -line "^ {$min}" $text {} text
    }
    return $text
}
