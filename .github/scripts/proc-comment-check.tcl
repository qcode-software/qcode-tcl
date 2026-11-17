set repository [lindex $argv 0]
set files [lrange $argv 1 end]

package require qcode-linter

puts "Checking procs have a #| comment in files that have changed."

set tcl_files [lmap x $files {file join $repository $x}]
puts [procs_without_proc_comment_report $tcl_files]
set count [procs_without_proc_comment_count $tcl_files]

if { $count > 0 } {
    exit 1
}
