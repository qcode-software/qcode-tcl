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

    set ::conn_info_superuser_test_db(host) $hostname
    set ::conn_info_superuser_test_db(dbname) test_database
    set ::conn_info_superuser_test_db(port) $port
    set ::conn_info_superuser_test_db(user) $username
    set ::conn_info_superuser_test_db(password) $password

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
} 

set setup {
    # The test user configuration.
    qc::db_connect {*}[array get ::conn_info_superuser]
    db_dml {CREATE DATABASE test_database}
    qc::db_disconnect

    qc::db_connect {*}[array get ::conn_info_superuser_test_db]
    db_dml {SET client_min_messages = WARNING}    
    qc::db_init
    db_dml {
        CREATE USER test_user WITH PASSWORD 'test_password';
        GRANT ALL PRIVILEGES ON DATABASE test_database TO test_user;
        GRANT ALL PRIVILEGES ON ALL TABLES in SCHEMA public TO test_user;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES in SCHEMA public TO test_user;
    }
    qc::db_disconnect    
    
    # Establish a connection the qc::db way
    qc::db_connect {*}[array get ::conn_info_test]

    # Local config
    if { [file exists ~/.qcode-tcl] } {
        source ~/.qcode-tcl
    }
    
    # Bucket to runs tests against
    if { ![info exists ::env(aws_s3_test_bucket)] } {
        puts "==========================================================================================="
        puts "===== Please specify the S3 test bucket to use in your ~/.qcode-tcl Tcl config file ======="
        puts "==========================================================================================="
        error "Please specify the S3 test bucket to use in your ~/.qcode-tcl Tcl config file"
    }
    
    qc::param_set s3_file_bucket $::env(aws_s3_test_bucket)
    db_dml {
        insert into
        users(user_id,firstname,surname,email,password_hash,user_state)
        values(0,'Charlie','root','charlie@test.com','*','ACTIVE');
    }
}


set cleanup {
    # Cleanup the qc::db connection
    qc::db_disconnect
    
    qc::db_connect {*}[array get ::conn_info_superuser_test_db]
    db_dml {SET client_min_messages = WARNING}    
    db_dml $cleanup_qry    
    qc::db_disconnect
    
    # Cleanup 
    qc::db_connect {*}[array get ::conn_info_superuser]
    db_dml {DROP DATABASE IF EXISTS test_database}
    db_dml {DROP ROLE IF EXISTS test_user;}
    qc::db_disconnect    
}
