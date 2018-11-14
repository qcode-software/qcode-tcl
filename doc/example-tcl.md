###### Save this example to the tcl library as specified in your tcl library configuration

/var/www/alpha.co.uk/tcl/init.tcl

```tcl
ns_register_proc GET /hello.html hello

proc hello {} {
   set set_id [ns_conn form]
   set param_value [ns_set get $set_id foo]

   ns_return 200 text/html "Hello World. Value $param_value"
}
```

###### Implementation
http://alpha.co.uk/hello.html?foo=12


###### Output
Hello World. Value 12
