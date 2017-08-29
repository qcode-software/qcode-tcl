```tcl
#!/usr/bin/tclsh8.5

set params [split $env(QUERY_STRING) &]
foreach par $params {
       set pair [split $par =]
       set name [lindex $pair 0]
       set value [lindex $pair 1]
       regsub -all \\\+ $value " " value
       # Convert url-encoded characters like %20
       regsub -all -nocase {%([0-9a-f][0-9a-f])} $value \
               {[format %c 0x\1]} value
       set form($name) [subst $value]
       }
puts "Content-type: text/html\n"
puts "<html><head><title>CGI Reply Page - via Tcl</title></head>"
puts "<body bgcolor=white>TCL used in CGI - First Demo"
puts "foo: $form(foo)"
puts "bar: $form(bar)"
puts "</body>"
```
