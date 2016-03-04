proc qc::db_init {} {
    #| Initialises the database objects required by qcode-tcl

    # param table
    db_dml {
	CREATE TABLE IF NOT EXISTS param (
					  param_name varchar(50) PRIMARY KEY,
					  param_value text
					  );
    }

    # plain_text
    if { ![qc::db_domain_exists -no-cache plain_text]} {
	db_dml {
	    create domain plain_text as text
	    check(
		  value !~ '<([^>]+)>'
		  );
	}
    }

    # plain_string
    if {![qc::db_domain_exists -no-cache plain_string]} {
	db_dml {
	    create domain plain_string as varchar(255)
	    check(
		  value !~ '<([^>]+)>'
		  );
	}
    }

    # url
    if {![qc::db_domain_exists -no-cache url]} {
	db_dml {
	    create or replace function is_url(text)
	    returns boolean as \$\$
	    select \$1 ~ '^https?://[a-z0-9\-\.]+(:[0-9]+)?([a-zA-Z0-9_\-\.~+/%]+)?(\?[a-zA-Z0-9_\-\.~+/%=&]+)?(\#[a-zA-Z0-9_\-\.~+/%]+)?$';
	    \$\$ language sql immutable strict;

	    create domain url as text
	    check(
		  is_url(value)
		  );
	}
    }

    # url_path
    if {![qc::db_domain_exists -no-cache url_path]} {
	db_dml {
	    create or replace function is_url_path(text)
	    returns boolean as \$\$
	    select \$1 ~ '/([a-zA-Z0-9\-._~]|%[0-9a-fA-F]{2}|[!$&''()*+,;=:@]|/)*$';
	    \$\$ language sql immutable strict;

	    create domain url_path as text
	    check(
		  is_url_path(value)
		  );
	}
    }   
    
    # user_state
    if {![qc::db_enum_exists -no-cache user_state]} {
	db_dml {
	    CREATE TYPE user_state AS ENUM ('ACTIVE', 'DISABLED');
	}    
    }

    # perm_method
    if {![qc::db_enum_exists -no-cache perm_method]} {
	db_dml {
	    CREATE TYPE perm_method AS ENUM ('READ', 'WRITE', 'APPEND');
	}
    }

    
    # sequence
    foreach sequence {
	user_id_seq 
	file_id_seq 
	perm_category_id_seq 
	perm_class_id_seq 
	perm_id_seq
    } {
	if {![qc::db_sequence_exists -no-cache $sequence]} {
	    db_dml {
		CREATE SEQUENCE [db_quote_identifier $sequence];
	    }	
	}
    }

    # pgcryto
    if {[qc::db_extension_exists pgcrypto]} {
	db_dml {
	    CREATE OR REPLACE FUNCTION sha1(bytea) returns text AS $$
	    SELECT encode(digest($1, 'sha1'), 'hex')
	    $$ LANGUAGE SQL STRICT IMMUTABLE;
	}    
    } else {
	error "Extension \"pgcrypto\" is not installed" 
    }


    # qcode-tcl required tables
    db_dml {
	CREATE TABLE IF NOT EXISTS users (
					  user_id int PRIMARY KEY,
					  firstname varchar(255) NOT NULL,
					  surname varchar(255) NOT NULL,
					  email varchar(255) NOT NULL,
					  password_hash varchar(60) NOT NULL,
					  user_state user_state NOT NULL DEFAULT 'ACTIVE',
					  ip varchar(15)
					  );

	CREATE TABLE IF NOT EXISTS file (
					 file_id integer PRIMARY KEY DEFAULT nextval('file_id_seq'::regclass),
					 user_id integer NOT NULL REFERENCES users,
					 filename text NOT NULL,
					 data bytea NOT NULL,
					 upload_date timestamp without time zone DEFAULT now(),
					 mime_type text NOT NULL
					 );

        CREATE TABLE IF NOT EXISTS image (
					  file_id int primary key references file on delete cascade,
					  width int,
					  height int
					  );

	CREATE TABLE IF NOT EXISTS validation_messages (
							table_name text NOT NULL,
							column_name text NOT NULL,
							message varchar(255) NOT NULL
							);

	

	


	CREATE TABLE IF NOT EXISTS session (
					    session_id text PRIMARY KEY,
					    time_created timestamp(0) WITHOUT time zone DEFAULT now() NOT NULL,
					    time_modified timestamp(0) WITHOUT time zone DEFAULT now() NOT NULL,
					    hit_count integer DEFAULT 0 NOT NULL,
					    ip varchar(15),
					    user_id integer NOT NULL REFERENCES users,
					    effective_user_id integer,
					    authenticity_token varchar(100)
					    );

	CREATE TABLE IF NOT EXISTS schema (
					   version int NOT NULL
					   );
    }

    # Initialise schema version.
    db_0or1row {select version from schema} {
	db_dml "INSERT INTO schema VALUES(1);"
    }
    
    db_dml {
	CREATE TABLE IF NOT EXISTS perm_category (
						  perm_category_id int PRIMARY KEY,
						  description text
						  );


	CREATE TABLE IF NOT EXISTS perm_class (
					       perm_class_id int PRIMARY KEY,
					       perm_name varchar(50) NOT NULL UNIQUE,
					       description text,
					       perm_category_id int REFERENCES perm_category
					       );


	CREATE TABLE IF NOT EXISTS perm (
					 perm_id int PRIMARY KEY,
					 perm_class_id int NOT NULL REFERENCES perm_class ON DELETE CASCADE,
					 method perm_method NOT NULL,
					 unique(perm_class_id, method)
					 );

	CREATE TABLE IF NOT EXISTS user_perm (
					      user_id int NOT NULL REFERENCES users ON DELETE CASCADE,
					      perm_id int NOT NULL REFERENCES perm ON DELETE CASCADE,
					      unique(user_id, perm_id)
					      );


	CREATE TABLE IF NOT EXISTS sticky (
					   user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
					   name varchar(255),
					   value varchar(255) ,
					   url varchar(255)
					   );

	CREATE TABLE IF NOT EXISTS file_alias_path (
						    url_path text PRIMARY KEY,
						    file_id int REFERENCES file(file_id) NOT NULL
						    );
    }
}
