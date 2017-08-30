An Introduction to Qcode Tcl
========
part of [Qcode Documentation](index.md)

-----
### Prerequisites

In order to use Qcode Tcl you need to have a working naviserver instance. You should follow the instructions [here](naviserver-introduction.md) to set up an instance if you do not already have one, and you should use the [Tcl Library config file](naviserver-config-tcl.md). 

-----
### Installing Qcode Tcl

Qcode Tcl is provided as a Debian package to facilitate a simple installation.  Simply run the following commands to install the Qcode Tcl library:

```
apt-get update
apt-get install qcode-tcl-8.0.0
```

-----
### Tcl Dependencies

Qcode Tcl has two fundamental dependencies:

* tcllib - includes implementations for many common data structures and formats such as mime, sha1, md5, fileutil
* tdom - for HTML, XML scripting

To install these, you should use the Debian package installations as follows:

```
apt-get install tcllib
apt-get install tdom
```

-----
### Hello World

Create the file `/var/www/alpha.co.uk/tcl/init.tcl` containing the code below.

```
package require qcode
namespace import qc::*

ns_register_proc GET /* qc::handler_restful

register GET /hello.html {} {
    #| Hello World using handler_restful
    return "Hello World"
}
```

Visit the page `http://localhost/hello.html` and you will see the text "Hello World".
