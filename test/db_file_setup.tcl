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
    drop table if exists param cascade;
    drop domain if exists plain_text cascade;
    drop domain if exists plain_string cascade;
    drop domain if exists url cascade;
    drop domain if exists url_path cascade;
    drop type if exists user_state cascade;
    drop type if exists perm_method cascade;
    drop sequence if exists user_id_seq cascade; 
    drop sequence if exists file_id_seq cascade;
    drop sequence if exists perm_category_id_seq cascade;
    drop sequence if exists perm_class_id_seq cascade;
    drop sequence if exists perm_id_seq cascade;
    drop extension if exists pgcrypto cascade;
    drop function if exists sha1 cascade;
    drop table if exists users cascade;
    drop table if exists file cascade;
    drop table if exists image cascade;
    drop table if exists validation_messages cascade;
    drop table if exists session cascade;
    drop table if exists schema cascade;
    drop table if exists perm_category cascade;
    drop table if exists perm_class cascade;
    drop table if exists perm cascade;
    drop table if exists user_perm cascade;
    drop table if exists sticky cascade;
    drop table if exists file_alias_path cascade;
    drop table if exists form cascade;
    drop table if exists required cascade;
    drop table if exists optional cascade;
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
    qc::param_set s3_file_bucket mla-dev-files
    qc::aws_credentials_set_from_ec2_role
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
