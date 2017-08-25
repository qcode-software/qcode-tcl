An Introduction to Qcode TCL
========
part of [Qcode Documentation](index.md)

* * *

### Installation

Qcode TCL is provided as a Debian package to facilitate a simple installation.  If you have previously installed Naviserver using the Qcode Debian package you should have the following line in your apt sources file (`/etc/apt/sources.list`) other wise you will need to add it:

```
deb http://debian.qcode.co.uk jessie main
```

Once you've added the apt source above, you should then be able to run the following commands to install the Qcode TCL library:

```
apt-get update
apt-get install qcode-tcl-8.0.0
```

(The version number above was correct at the time of install, you will need to substitute in the latest version number - easily found by looking at the packages in the list shown at `http://debian.qcode.co.uk/debs/`).

-----
### Dependencies / Prerequisites

While every effort has been made to keep Qcode TCL a standalone package, there are a couple of fundamental dependencies that are required.

* tcllib - includes implementations for many common data structures and formats such as mime, sha1, md5, fileutil
* tdom - for HTML, XML scripting

To install these, you can use the Debian package installations as follows:

```
apt-get install tcllib
apt-get install tdom
```

-----
### Implementing Qcode TCL

Once you've got the Debian package installed we can include the Qcode TCL library into a project and begin working with it.  You'll need to have followed the naviserver set-up that includes implementing a tcl library, and any tcl files you create should be saved into the directory you specify during that set-up.

At the top of any tcl file where you need to work with the Qcode TCL library you should include the following code:

```
# import the qcode-tcl library
package require qcode
```

If following the example of our naviserver tcl procedure, this would be under `/var/www/alpha.co.uk/tcl`.

-----
### Testing Your Implementation

A simple test to make sure you can connect to the Qcode tcl library is to reference once of the procs inside the library and return some basic data.

For this exercise we can use the handler_restful proc which provides an interface over ns_register_proc that includes connection handling and returning correctly formatted HTML data.

The following code, saved as a .tcl file in your active directory should, when visiting the page "qcode.html", return the message "Hello World" as a valid HTML response.

```
package require qcode
namespace import qc::*

ns_register_proc GET /* qc::handler_restful

register GET /qcode.html {} {
    #| Hello World using handler_restful
    return "Hello World"
}
```
