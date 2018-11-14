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
ns_section      "ns/server/${server_name}/modules"
   ns_param         nssock          ${homedir}/bin/nssock.so
   ns_param         nsdb            ${homedir}/bin/nsdb.so
   ns_param         nscp            ${homedir}/bin/nscp.so

# nssock address configuration
ns_section "ns/server/${server_name}/module/nssock"
  ns_param     port                    $port
  ns_param     address                 $address

# Global Parameters
ns_section      "ns/parameters"
   # Home directory for the server (resolved automatically if not specified)
   ns_param	home	$homedir
   # Main server log file
   ns_param    serverlog       /var/log/${package}/${server_name}.log
   # Pid file of the server process
   ns_param	pidfile         /var/run/${package}/${server_name}.pid

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

# nscp  configuration
ns_section "ns/server/${server_name}/module/nscp"
  ns_param     port                    9980
  ns_param     address                 $address

ns_section "ns/server/${server_name}/module/nscp/users"
  ns_param     user                    "nsd:t2GqvvaiIUbF2:"

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
   ns_param     datasource      127.0.0.1:5432:test
  # username of postgres user
  ns_param     user            web
  # password of postgres user
  ns_param     password        pass123
  # Number of connections allowed
  ns_param     connections      1

# Database pool configuration
ns_section      "ns/server/${server_name}/db"
  ns_param     pools           "*"
  ns_param     defaultpool     "main"
