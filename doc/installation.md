An Introduction to Qcode TCL
========
part of [Qcode Documentation](index.md)

* * *
### Prerequisites

In order to use Qcode TCL you need to have a working naviserver instance. You can follow the instructions [here](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-introduction.md) to set up an instance if you do not already have one, you should use the TCL Library [config file](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-tcl.md). 

-----
### Installation

Qcode TCL is provided as a Debian package to facilitate a simple installation.  Simply run the following commands to install the Qcode TCL library:

```
apt-get update
apt-get install qcode-tcl-8.0.0
```

(The version number above was correct at the time of writing, you will need to substitute in the latest version number - easily found by looking at the packages in the list shown at `http://debian.qcode.co.uk/debs/`).

-----
### Dependencies / Prerequisites

Qcode TCL has two fundamental dependencies:

* tcllib - includes implementations for many common data structures and formats such as mime, sha1, md5, fileutil
* tdom - for HTML, XML scripting

To install these, you should use the Debian package installations as follows:

```
apt-get install tcllib
apt-get install tdom
```

-----
### Implementing Qcode TCL

Once you've got the Debian package installed we can include the Qcode TCL library into a project and begin working with it.  At the top of any tcl file where you need to work with the Qcode TCL library you should include the following code:

```
# import the qcode-tcl library
package require qcode
```

-----
### Hello World

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
