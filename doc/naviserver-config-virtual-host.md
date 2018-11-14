```tcl
#
# This is a Naviserver config file to configure server to listen
# on same IP and port for multiple hostnames.
#

set package naviserver

# Absolute path to the installation directory
set homedir /usr/lib/${package}

# Name of the virtual server
set server_name_1 alpha
set server_name_2 beta

# Address and port for nssock
# 
# For non-standard ports you must append the port to the server name as well as defining it here:
# e.g. set port 8080
#
set address 127.0.0.1
set port    80

# Modules of Main server
ns_section "ns/modules"
    ns_param   nssock    ${homedir}/bin/nssock.so

# Modules of Virtual server 1
ns_section "ns/server/$server_name_1/modules"
    ns_param   nslog     ${homedir}/bin/nslog.so

# Modules for virtual server 2
ns_section "ns/server/$server_name_2/modules"
    ns_param   nslog     ${homedir}/bin/nslog.so

# Global parameters
ns_section "ns/parameters"
    # Home directory for the server (resolved automatically if not specified)
    ns_param   home        $homedir
    # Main server log file
    ns_param   serverlog   /var/log/${package}/virtual-host.log
    # Pid file of the server process
    ns_param   pidfile     /var/run/${package}/virtual-host.pid

# Servers
ns_section "ns/servers"
    # server 1
    ns_param   $server_name_1   "Naviserver $server_name_1"
    # server 2
    ns_param   $server_name_2   "Naviserver $server_name_2"

# nslog configuration server 1
ns_section "ns/server/${server_name_1}/module/nslog"
    # Name of the log file
    ns_param   file           /var/log/${package}/${server_name_1}-access.log     

# nslog configuration server 2
ns_section "ns/server/${server_name_2}/module/nslog"
    # Name of the log file
    ns_param   file           /var/log/${package}/${server_name_2}-access.log     

# nssock configuration 
ns_section "ns/module/nssock"
    ns_param   port            $port
    ns_param   address         $address
    ns_param   defaultserver   $server_name_1

# 
# Include port if using non-standard
# e.g. ns_param  $server_name_1  alpha.co.uk:8080
# 
ns_section "ns/module/nssock/servers"
    ns_param   $server_name_1    alpha.co.uk
    ns_param   $server_name_2    beta.co.uk

# Fastpath server 1
ns_section "ns/server/${server_name_1}/fastpath"
    # Path to all html/adp pages (absolute or relative to server directory)
    ns_param   pagedir         /var/www/alpha.co.uk/
    # Default page to look for
    ns_param   directoryfile   "index.html"

# Fastpath server 2
ns_section "ns/server/${server_name_2}/fastpath"
    ns_param   pagedir         /var/www/beta.co.uk/
    ns_param   directoryfile   "index.html"
```
