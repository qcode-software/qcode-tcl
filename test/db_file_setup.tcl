if { [info commands ns_db] ne "ns_db" } {
    # Load all .tcl files
    set files [lsort [glob -nocomplain [file join "../tcl" *.tcl]]]
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

    # initialise db credentials

    set ::conn_info_test(host) $hostname
    set ::conn_info_test(port) $port
    array set ::conn_info_test {
        dbname test_database
        user test_user
        password test_password
    }
} 

set setup_qry {

}

set cleanup_qry {
    drop table param cascade;
} 

set setup {
    # The test user configuration.
    set conn_superuser [qc::db_connect {*}[array get ::conn_info_superuser]]
    db_dml {CREATE DATABASE test_database}
    db_dml {
        CREATE USER test_user WITH PASSWORD 'test_password';
        GRANT ALL PRIVILEGES ON DATABASE test_database TO test_user;
        SET client_min_messages = WARNING;
    }
    qc::db_init
    qc::db_disconnect
    
    # Establish a connection the qc::db way
    set conn [qc::db_connect {*}[array get ::conn_info_test]]
    qc::db_connect $conn    
    qc::param_set s3_file_bucket mla-dev-files
    qc::aws_credentials_set_from_ec2_role 
}


set cleanup {
    # Cleanup the qc::db connection
    set conn [qc::db_connect {*}[array get ::conn_info_test]]
    qc::db_disconnect
    
    # Cleanup 
    set conn_superuser [qc::db_connect {*}[array get ::conn_info_superuser]]
    #db_dml $cleanup_qry
    #db_dml {DROP DATABASE IF EXISTS test_database}
    #db_dml {DROP ROLE IF EXISTS test_user;}
    qc::db_disconnect
    
}
