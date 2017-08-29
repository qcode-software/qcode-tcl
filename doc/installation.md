An Introduction to Naviserver & Qcode Tcl
========
part of [Qcode Documentation](index.md)

* * *
### Installing Naviserver

In order to get naviserver up and running on your virtual machine you should first link your debian packages installer to the qcode package repository by adding the following line to your apt sources file (`/etc/apt/sources.list`) substituting jessie for your debian version.

```
deb http://debian.qcode.co.uk jessie main
```

Once you've added the apt source above, you should then run the following commands to install naviserver.

```
apt-get update
apt-get install naviserver
```

You will also need to install the naviserver support packages:

```
apt-get install naviserver-dev naviserver-dbg naviserver-nsdbpg
```

-----
### Configuring Naviserver

To install the correct config for Naviserver to ensure Tcl runs, you'll need to create a file `/env/naviserver/alpha.tcl` and add code to configure naviserver correctly.

```
#
# This is a Naviserver config file that enables tcl library
#

# Derive server_name from config file name.
set server_name [string map {".tcl" ""} [file tail [ns_info config]]]
set package naviserver

# Absolute path to the installation directory
set homedir /usr/lib/${package}

# The hostname, address and port for nssock 
set port 80
set hostname localhost
set address 127.0.0.1

# Servers
ns_section      "ns/servers"
    # first server
    ns_param         $server_name         Naviserver

# Modules
ns_section      "ns/modules"
    ns_param         nssock          ${homedir}/bin/nssock.so

# Global Parameters
ns_section      "ns/parameters"
    # Home directory for the server (resolved automatically if not specified)
    ns_param	home		$homedir
    # Main server log file
    ns_param    serverlog       /var/log/${package}/${server_name}.log
    # Pid file of the server process
    ns_param	pidfile         /var/run/${package}/${server_name}.pid

# nssock server configuration 
ns_section 	"ns/module/nssock/servers"
   # Server and its address
   ns_param   	$server_name    "Naviserver $server_name"

# nssock address configuration
ns_section 	"ns/module/nssock"
   ns_param     port                $port
   ns_param     address             $address
   ns_param   	defaultserver   	$server_name

# Fastpath 
ns_section        "ns/server/${server_name}/fastpath"
   # Path to all html/adp pages (absolute or relative to server directory)
   ns_param       pagedir          /var/www/alpha.co.uk
   # Default page to look for
   ns_param       directoryfile    "index.html"

# Tcl library configuration
ns_section        "ns/server/${server_name}/tcl"
   # Path of tcl library
   ns_param       library          /var/www/alpha.co.uk/tcl
```

In a terminal window you should now run this command to start your Naviserver instance.

```
systemctl start naviserver@alpha
```

In order to check that your naviserver is listening on the correct port, you can run the command:

```
netstat -46lnp
```

You should be able to see a line similar to the following in the results:

```
tcp    0    0 0.0.0.0:80    0.0.0.0:*    LISTEN    123/nsd  
```

That tells us that the nsd (naviserver) service is running and listening on port 80.  To check that naviserver is correctly serving pages, you can visit `http://localhost/`.

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
