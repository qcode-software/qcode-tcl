### An Introduction to Naviserver
-----

### Preamble

A lot of the following commands and edits need administrator level privileges, so if any of the following return permission based error messages, it's likely either a case of chmod'ing a file, or sudo'ing a command.

-----
### Installing Naviserver

In order to get naviserver up and running on your virtual machine you should first link your debian packages installer to the qcode package repository.

You can do this by adding the following line to your apt sources file (`/etc/apt/sources.list`) substituting jessie for your debian version.

```
deb http://debian.qcode.co.uk jessie main
```

Once you've added the apt source above, you should then be able to run the following commands to install naviserver (remember, you may need to prefix these commands with sudo for permission):

```
apt-get update
apt-get install naviserver
```

You can then also install the naviserver support packages:

```
apt-get install naviserver-dev naviserver-dbg naviserver-nsdbpg
```

-----
### Configuring Naviserver

Once you've got naviserver installed, you should first try and get everything running with a [minimal config](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-minimal.md).  Once you've done this, you can try different config files, alternative setups and various options.

To install the minimal config, you'll need to navigate to `/env/naviserver/` and create a minimal.tcl file.  We can then add code to this file to configure naviserver correctly.

It's worth noting that Linux requires root privileges for ports 0 - 1024, so if you're setting up a webserver to run under one of those ports you will need to use the "-b" option to prebind the specified port as root then fork the process to run under the requested the user.

While this is not necessary for port 8080, we have included the code in our example for sake of completion.  Our setup uses an "instance.env" file to add the -b options to the config, though this file is not required.

If we create minimal.env and add the following we will be setting up the server to run on port 8080 as the root user:

```
OPTS="-b 0.0.0.0:8080"
```

The minimal.tcl file should then contain the following:

```tcl
set server_name [string map {".tcl" ""} [file tail [ns_info config]]]
set package naviserver
```

- The above code sets the server up using the name of this config file as a name

```tcl
set homedir /usr/lib/${package}
```

- Absolute path to the installation directory

```tcl
set port 8080
set hostname localhost
set address 0.0.0.0
```

- The hostname, address and port to be used for nssock, essentially where the site will be served.

```tcl
ns_section      "ns/servers"
    ns_param         $server_name         Naviserver
```

- Set up the server, multiple servers via virtual hosts would require multiple servers - more about this in the section [Virtual Hosts](#multiple-sites-via-virtual-hosts)

```tcl
ns_section      "ns/modules"
    ns_param         nssock          ${homedir}/bin/nssock.so
```

- Set up the modules needed to run this server.  nssock is the bare minimum, used for socket communication via HTTP.

```tcl
ns_section      "ns/parameters"
    ns_param	  home		     $homedir
    ns_param    serverlog    /var/log/${package}/${server_name}.log
    ns_param	  pidfile      /var/run/${package}/${server_name}.pid
```

- Global parameters for the server, in this instance - the home directory for the server, where the main log file is stored and the process ID of the server package.

```tcl
ns_section 	"ns/module/nssock/servers"
   ns_param   	$server_name    ${hostname}:${port}
```

- Basic server config for nssock using hostname and port

```tcl
ns_section 	"ns/module/nssock"
   ns_param   	port            	$port
   ns_param   	hostname        	$hostname
   ns_param   	address         	$address
   ns_param   	defaultserver   	$server_name
```

- Default address configuration for nssock

```tcl
ns_section        "ns/server/${server_name}/fastpath"
   ns_param       pagedir          /var/www/alpha.co.uk
   ns_param       directoryfile    "index.html"
```

- Setting up the path to your html files and default document

-----
### Getting It Started

Once you have created the two files above, you can start the naviserver service on your dev box. Once that is done you should be able to access your server on localhost:8080.

If naviserver has been set up correctly through the debian package there should be a service up and running already, which you will need to restart in order to activate your new bindings for "minimal". To check for this service, use:

```
systemctl status naviserver@*
```

If you then substitute naviserver@minimal instead of naviserver@\* you can check to see if your minimal config files have been picked up.  The service should be loaded but not active.  To check whether this service is running, use:

```
systemctl status naviserver@minimal
```

If it's not running, for example if it's loaded but inactive, you can activate it using:

```
systemctl start naviserver@minimal
```

To restart it if you have made an amendment to your config file, use:

```
systemctl restart naviserver@minimal
```

If you receive any error messages while starting up your server, outside of permissions based errors which should be easily identifiable and simple to rectify, you may need to check your naviserver log. Like most linux logs, this can be found under `/var/log/` specifically in this case at `/var/log/naviserver/minimal.log`

-----
### Testing your install

In order to check that your naviserver is listening on the correct port, you can run the command:

```
netstat -46lnp
```

You should be able to see a line similar to the following in the results:

```
tcp    0    0 0.0.0.0:8080    0.0.0.0:*    LISTEN    123/nsd  
```

That tells us that the nsd (naviserver) service is running and listening on port 8080.  To check that naviserver is correctly serving pages, you can visit localhost:8080.

In order to see something meaningful in there, you can upload a basic index.html file to `/var/www/alpha.co.uk` (or again whatever directory you created as your site folder).

-----
### Multiple sites via Virtual Hosts

To allow multiple sites to be hosted on the same IP address you can set up a config file that will tell naviserver to look for host headers in order to determine which content should be served.

In the [example config](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-virtual-host.md) file you can see that we've added multiple server names.  The nssock module is still running globally in order to handle the socket connections, but we've shown an example of "instanced" nslog modules running under each of these servers.

In order to test host headers on your dev environment you can use the hosts file (`/etc/hosts`) to simulate how visitors would be directed to the relevant site. In the case of the virtual housts config file provided, you could test this functionality by adding the following lines to your hosts file:

```
127.0.0.1    alpha.co.uk
127.0.0.1    beta.co.uk
```

-----
### Serving pages via TCL

In order to provision a server capable of serving dynamic pages, rather than static HTML, you will need to include the nscgi module, as in the provided [CGI config file](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-cgi.md).

Most of the setup should be the same as the minimal config, with the noted addition of the following lines:

```tcl
# CGI
ns_section      "ns/server/${server_name}/module/nscgi"
    ns_param    map             "GET /cgi-bin /usr/local/cgi-bin"
    ns_param    map             "POST /cgi-bin /usr/local/cgi-bin"
    ns_param    interps         CGIinterps

# Interpreter
ns_section      "ns/interps/CGIinterps"
    ns_param    .tcl            "/usr/bin/tclsh8.5"
```

These lines tell naviserver what action to carry out when receiving GET and POST requests, and which interpreter to use to decipher those requests, in this case tcl 8.5

With this in place, you can then put .tcl files into your `/usr/local/cgi-bin` directory (as defined in the CGI section) and connect to them from your html pages.

You could also connect to a tcl library using the following code:

```tcl
ns_section      "ns/server/${server_name}/tcl"
    ns_param    library    /var/www/alpha.co.uk/tcl
```

You can then serve content directly from this tcl directory using some naviserver tcl commands such as ns_register_proc to bind a request method and path (i.e GET /hello.html) to a tcl proc that can return html code.

-----
### Adding Postgresql to the mix

The last set of files demonstrate how to connect a naviserver instance to postgresql, such as this [postgres config file](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-postgres.md).  You can then use tcl and postgresql to query and return data from a database.

You will need to install and set up a database in Postgresql before being able to connect using the following code, it's recommended you take a look [here](postgresql-setup.md) for help getting set up.

The config options are fairly straightforward for postgresql:

```tcl
# Drivers configuration
ns_section      "ns/db/drivers"
    ns_param    postgres    ${homedir}/bin/nsdbpg.so
```

- Set up the path to the postgres drivers

```tcl
# Database pool
ns_section      "ns/db/pools"
    ns_param    main            "Main Pool"

ns_section      "ns/server/${server_name}/db"
    ns_param    pools           "*"
    ns_param    defaultpool     "main"
```

- Connect to, and configure, the database pool. All of your postgres requests will connect to this pool.

```tcl
ns_section      "ns/db/pool/main"
    ns_param    driver          postgres
    ns_param    datasource      127.0.0.1:5432:testdb
    ns_param    user            priyank
    ns_param    password        "123"
    ns_param    connection      1
```

- Set up and connect to the postgres server, passing in the datasource (comprising server IP, port and database name), username, and password.

With all of the above added to your config file, you should then be able to connect to postgres using tcl naviserver database commands. A few examples are provided on the [example configs page](https://github.com/qcode-software/qcode/blob/master/wiki/naviserver-config-examples.md).
