```tcl
#
# This is a Naviserver config file to configure server to execute program
# as a CGI
#

# Derive server_name from config file name.
set server_name  [string map {".tcl" ""} [file tail [ns_info config]]]
set package     naviserver

# Absolute path to the installation directory
set homedir     /usr/lib/${package}

# Address and port for nssock
set port        80
set hostname    localhost
set address     127.0.0.1

# Servers
ns_section      "ns/servers"
   ns_param     $server_name     "Naviserver $server_name"

# Modules
ns_section      "ns/modules"
   ns_param     nssock          ${homedir}/bin/nssock.so

ns_section      "ns/server/${server_name}/modules"
   ns_param     nscgi           ${homedir}/bin/nscgi.so
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
# Remember to change "alpha.co.uk" to ${hostname}:${port} if using non-standard ports
ns_section 	"ns/module/nssock/servers"
   ns_param   	$server_name     alpha.co.uk

ns_section 	"ns/module/nssock"
   ns_param     port            $port
   ns_param     hostname        $hostname
   ns_param     address         $address
   ns_param   	defaultserver   $server_name

# Fastpath
ns_section      "ns/server/${server_name}/fastpath"
   # Path to all html/adp pages (absolute or relative to server directory)
   ns_param     pagedir         /var/www/alpha.co.uk
   # Default page to look for
   ns_param     directoryfile   "index.html"

# CGI
ns_section      "ns/server/${server_name}/module/nscgi"
   # CGI script file directory mapping GET
   ns_param     map             "GET /cgi-bin /usr/local/cgi-bin"
   # CGI script file directory mapping POST
   ns_param     map             "POST /cgi-bin /usr/local/cgi-bin"
   # Name of the interpreter section
   ns_param     interps         CGIinterps

# Interpreter
ns_section      "ns/interps/CGIinterps"
   # Path to interpreter
   ns_param     .tcl            "/usr/bin/tclsh"
   
```
