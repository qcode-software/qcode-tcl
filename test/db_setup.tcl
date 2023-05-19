# Common definitions of setup and cleanup

if { [info commands ns_db] ne "ns_db" } {
    # Load all .tcl files
    package require fileutil
set files [lsort [fileutil::findByPattern "~/qcode-tcl/tcl" "*.tcl"]]
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
    SET client_min_messages = WARNING;
    CREATE TABLE courses (
                          course_id    int PRIMARY KEY,
                          title        varchar(40)
                          );
    INSERT INTO courses VALUES
    (0, 'Computer Science'),
    (1, 'Art & Design'),
    (2, 'International Copyright Law');
    CREATE TABLE students (
                           student_id   int PRIMARY KEY,
                           firstname    varchar(30) NOT NULL,
                           surname      varchar(30) NOT NULL,
                           dob          date,
                           course_id    int REFERENCES courses
                           );
    INSERT INTO students VALUES
    (012345, 'John', 'Smith', '1980-01-01', 0),
    (192837, 'Jane', 'Doe', '1990-03-31', 2),
    (246810, 'Sam', 'Brown', '1985-05-15', 1),
    (007123, 'Max', 'Power', '1989-08-09', 1);
    CREATE SEQUENCE course_id_sequence START 3;
}

set cleanup_qry {
    drop table students cascade;
    drop table courses cascade;
    drop sequence course_id_sequence;
} 

set setup_inside_naviserver {
    # The test user configuration.
    set db [qc::db_get_handle]
    ns_db dml $db $setup_qry
}

set setup_outside_naviserver {
    # The test user configuration.
    set conn_superuser [pg_connect -connlist [array get ::conn_info_superuser]]
    pg_execute $conn_superuser {CREATE DATABASE test_database}
    pg_execute $conn_superuser {
        SET client_min_messages TO WARNING;
        drop user if exists test_user;
        CREATE USER test_user WITH PASSWORD 'test_password';
        GRANT ALL PRIVILEGES ON DATABASE test_database TO test_user;
        CREATE USER test_user_no_membership;
        CREATE USER test_user_with_membership in role test_user;
    }
    pg_disconnect $conn_superuser
    
    # Establish a connection the qc::db way (default pool)
    set conn [qc::db_connect {*}[array get ::conn_info_test]]
    # execute setup queries
    pg_execute $conn $setup_qry
    # Establish a connection the qc::db way (alt pool)
    qc::db_connect -poolname alt {*}[array get ::conn_info_test]
}

set cleanup_inside_naviserver {
    # Cleanup the qc::db connection
    set db [qc::db_get_handle]
    ns_db dml $db $cleanup_qry 
}

set cleanup_outside_naviserver {
    # Cleanup the qc::db connection (default pool)
    set conn [qc::db_connect {*}[array get ::conn_info_test]]
    pg_execute $conn $cleanup_qry
    qc::db_disconnect
    # Cleanup the qc::db connection (alt pool)
    qc::db_disconnect -poolname alt
    
    # Cleanup 
    set conn_superuser [pg_connect -connlist [array get ::conn_info_superuser]]
    pg_execute $conn_superuser {DROP DATABASE IF EXISTS test_database}
    pg_execute $conn_superuser {
        DROP ROLE IF EXISTS test_user;
        DROP ROLE IF EXISTS test_user_no_membership;
        DROP ROLE IF EXISTS test_user_with_membership;
    }
    pg_disconnect $conn_superuser
    
}

if { [info commands ns_db] eq "ns_db" } {
    set setup $setup_inside_naviserver
    set cleanup $cleanup_inside_naviserver
} else {
    set setup $setup_outside_naviserver
    set cleanup $cleanup_outside_naviserver
}
