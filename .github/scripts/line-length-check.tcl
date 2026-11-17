set max_line_length [lindex $argv 0]
set repository [lindex $argv 1]
set files [lrange $argv 2 end]

package require qcode-linter

puts "Checking line length is under $max_line_length chars in files that have changed."

set tcl_files [lmap x $files {file join $repository $x}]
puts [lines_over_length_report $tcl_files $max_line_length]
set count [lines_over_length_count $tcl_files $max_line_length]

if { $count > 0 } {
    exit 1
}
