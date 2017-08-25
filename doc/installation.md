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

Once you've got the Debian package installed we can include the Qcode TCL library into a project and begin working with it.

At the top of any tcl file where you need to work with the Qcode TCL library you should include the following code:

```
# import the qcode-tcl library
package require qcode
```

-----
### Testing Your Implementation

A simple test to make sure you can connect to the Qcode tcl library is to reference once of the procs inside the library and return some basic data.

For this exercise I'd recommend connecting to a proc that does not use the Qcode session management code, the connection marshalling or anything that requires that a database be set up.  To that end, using one of the error procs to return HTML to the page is the simplest way to check your implementation.

The following code, saved as a .tcl file in your active directory should, when visiting the page "qcode.html", return a "Software Bug" with the errorMessage "Hello World", the errorInfo "Test" and the errorCode "000".

```
package require qcode
namespace import qc::*

ns_register_proc GET /qcode.html qcode

proc qcode {} {
    ns_return 200 text/html [qc::error_report "Hello World" "Test" "000"]
}
```
