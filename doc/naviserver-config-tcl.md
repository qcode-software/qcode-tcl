```tcl
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
   ns_param     port                    $port
   ns_param     address                 $address
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
