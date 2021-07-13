# Common definitions of setup and cleanup

if { [info commands ns_db] ne "ns_db" } {
    # Load all .tcl files
    set files [lsort [glob -nocomplain [file join [file dirname [file normalize [info script]]] "../tcl" *.tcl]]]
    foreach file $files {
        source $file
    }
    namespace import ::qc::*

    # Superuser credentials
    set pgpass_filename $::env(HOME)/.pgpass
    if { [pgpass_credentials_exist $pgpass_filename template1] } {
        dict2vars [pgpass_credentials $pgpass_filename template1] {*}{
            hostname
            database
            port
            username
            password
        }
    } else {
        error "Missing pgpass entry for db template1"        
    }
    set ::conn_info_superuser(host) $hostname
    set ::conn_info_superuser(dbname) $database
    set ::conn_info_superuser(port) $port
    set ::conn_info_superuser(user) $username
    set ::conn_info_superuser(password) $password

    set conn_info_superuser_test_database [dict create host $hostname dbname test_database port $port user $username password $password]

    # initialise db credentials

    set ::conn_info_test(host) $hostname
    set ::conn_info_test(port) $port
    array set ::conn_info_test {
        dbname test_database
        user test_user
        password test_password
    }
} 

set cleanup_qry {drop if exists extension pgcrypto} 

set setup_inside_naviserver {
    # The test user configuration.
    set db [qc::db_get_handle]
    ns_db dml $db $setup_qry
    set key secretkey
}

set setup_outside_naviserver {
    # The test user configuration.
    set conn_superuser [pg_connect -connlist [array get ::conn_info_superuser]]
    pg_execute $conn_superuser {
        SET client_min_messages TO WARNING;
    }
    pg_execute $conn_superuser {
        DROP database if exists test_database;
    }
    pg_execute $conn_superuser {
	CREATE DATABASE test_database;
    }
    pg_execute $conn_superuser {
        drop user if exists test_user;
	CREATE USER test_user WITH PASSWORD 'test_password';
        GRANT ALL PRIVILEGES ON DATABASE test_database TO test_user;
    }
    pg_disconnect $conn_superuser

    set conn [qc::db_connect {*}$conn_info_superuser_test_database]
    pg_execute $conn {
        SET client_min_messages TO WARNING;
    }
    pg_execute $conn {
        create extension if not exists pgcrypto
    }

    set key secretkey
}

set cleanup_inside_naviserver {
    # Cleanup the qc::db connection
    set db [qc::db_get_handle]
    ns_db dml $db $cleanup_qry

    unset key
}

set cleanup_outside_naviserver {
    # Cleanup the qc::db connection
    set conn [qc::db_connect {*}[array get ::conn_info_test]]
    pg_execute $conn {drop extension pgcrypto}
    qc::db_disconnect
    
    # Cleanup 
    set conn_superuser [pg_connect -connlist [array get ::conn_info_superuser]]
    pg_execute $conn_superuser {DROP DATABASE IF EXISTS test_database}
    pg_execute $conn_superuser {
        DROP ROLE IF EXISTS test_user;
    }
    pg_disconnect $conn_superuser

    unset key
}

if { [info commands ns_db] eq "ns_db" } {
    set setup $setup_inside_naviserver
    set cleanup $cleanup_inside_naviserver
} else {
    set setup $setup_outside_naviserver
    set cleanup $cleanup_outside_naviserver
}
