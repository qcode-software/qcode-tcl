```tcl
#
# This is a Naviserver config file to configure PostgreSQL
#

# Derive server_name from config file name.
set server_name  [string map {".tcl" ""} [file tail [ns_info config]]]
set package     naviserver

# Absolute path to the installation directory
set homedir     /usr/lib/${package}

# Address and port for nssock
set port        80
set address     127.0.0.1

# Servers
ns_section      "ns/servers"
   ns_param     $server_name     "Naviserver $server_name"

# Modules
ns_section      "ns/server/${server_name}/modules"
   ns_param     nssock          ${homedir}/bin/nssock.so
   ns_param     nsdb            ${homedir}/bin/nsdb.so
   ns_param     nslog           ${homedir}/bin/nslog.so

# Global parameters
ns_section      "ns/parameters"
   # Home directory for the server (resolved automatically if not specified)
   ns_param	home		$homedir
   # Main server log file
   ns_param     serverlog       /var/log/${package}/${server_name}.log
   # Pid file of the server process
   ns_param	pidfile         /var/run/${package}/${server_name}.pid

# nslog configuration
ns_section      "ns/server/${server_name}/module/nslog"
   # Name of the file
   ns_param     file            /var/log/${package}/${server_name}-access.log

# nssock configuration
ns_section 	"ns/module/nssock/servers"
   ns_param   	$server_name     alpha.co.uk

ns_section 	"ns/module/nssock"
   ns_param     port            $port
   ns_param     address         $address
   ns_param   	defaultserver   $server_name

# Fastpath
ns_section      "ns/server/${server_name}/fastpath"
   # Path to all html/adp pages (absolute or relative to server directory)
   ns_param     pagedir         /var/www/alpha.co.uk
   # Default page to look for
   ns_param     directoryfile   "index.html"

#############################
# PostgreSQL configurations #
#############################
# Drivers configuration
ns_section      "ns/db/drivers"
   # Path to postgres drivers
   ns_param     postgres          ${homedir}/bin/nsdbpg.so

# Database pool
ns_section      "ns/db/pools"
   ns_param     main            "Main Pool"

ns_section      "ns/db/pool/main"
   ns_param     driver          postgres
   # IP address, port and name of the postgres database
   ns_param     datasource      127.0.0.1:5432:testdb
   # username of postgres user
   ns_param     user            priyank
   # password of postgres user
   ns_param     password        "123"
   # Number of connections allowed
   ns_param     connection      1

# Database pool configuration
ns_section      "ns/server/${server_name}/db"
   ns_param     pools           "*"
   ns_param     defaultpool     "main"

# Tcl library configuration
ns_section        "ns/server/${server_name}/tcl"
   # Path of tcl library
   ns_param       library          /var/www/alpha.co.uk/tcl
```
