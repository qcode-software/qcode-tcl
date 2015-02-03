Data Model Dependencies
=======================
part of [Qcode Documentation](index.md)

* * *

Certain parts of the qcode-tcl library are dependent upon a data model being in place and other parts depend upon specific tables existing. Below are the procs and their dependents along with the SQL statements to add the data model dependency.


Procs & Data Model Dependencies
-------------------------------

Proc | Table(s) | Other
-----|----------|------
| `qc::validate2model` | [validation_messages] | 
| `qc::handlers validate2model` | [validation_messages] | 
| `qc::filter_validate` | [validation_messages] |
| `qc::filter_authenticate` | [session], [users] | [Anonymous User]
| `qc::filter_file_alias_path` | [file], [file_alias_path] | 
| `qc::session_new` | [session], [users] | [pgcrypto]
| `qc::session_authenticity_token` | [session], [users] | 
| `qc::session_update` |  [session], [users] | 
| `qc::session_sudo_logout` | [session], [users] | 
| `qc::session_kill` | [session], [users] | 
| `qc::session_exists` | [session], [users] | 
| `qc::session_valid` | [session], [users] | 
| `qc::session_user_id` | [session], [users] | 
| `qc::session_sudo` | [session], [users] | 
| `qc::session_purge` | [session], [users] | 
| `qc::anonymous_session_id` | [session], [users] | [Anonymous User]
| `qc::schema_update` | [schema] | 
| `qc::sticky_set` | [sticky], [users] | 
| `qc::sticky_save` | [sticky], [users] | 
| `qc::sticky_get` | [sticky], [users] | 
| `qc::sticky_exists` | [sticky], [users] |
| `qc::sticky2vars` | [sticky], [users] |
| `qc::sticky_default` | [sticky], [users] | 

### pgcrypto

The [pgcrypto module] for PostgreSQL provides cryptographic functions - some of which are used by procs in the library. In order to install the pgcrypto extension the [postgresql-contrib] package will need to be installed first.


```SQL
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION sha1(bytea) returns text AS $$
    SELECT encode(digest($1, 'sha1'), 'hex')
$$ LANGUAGE SQL STRICT IMMUTABLE;
```

### Anonymous User

The anonymous session depends upon a user with the ID -1 being present in the `users` table. This is a special ID chosen for the anonymous user and should be reserved for it.

As an example:

```TCL
# Generate a password hash for the anonymous user
set password_hash [qc::password_hash TheAnonymousUserCreepsSilentlyIntoTheDatabase]
db_dml {
    INSERT INTO
    users (user_id, firstname, surname, email, password_hash)
    VALUES
    (-1, 'anonymous', 'anonymous', 'anonymous@qcode.co.uk', :password_hash
);

```

Tables
------

### validation_messages

```SQL
CREATE TABLE validation_messages (
    table_name text NOT NULL,
    column_name text NOT NULL,
    message varchar(255) NOT NULL
);
```

### users

```SQL
CREATE TYPE user_state AS ENUM ('ACTIVE', 'DISABLED');

CREATE SEQUENCE user_id_seq;

CREATE TABLE users (
    user_id int PRIMARY KEY,
    firstname varchar(255) NOT NULL,
    surname varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    password_hash varchar(60) NOT NULL,
    user_state user_state NOT NULL DEFAULT 'ACTIVE'
);
```

### session

```SQL
CREATE TABLE session (
   session_id text PRIMARY KEY,
   time_created timestamp(0) without time zone DEFAULT now() NOT NULL,
   time_modified timestamp(0) without time zone DEFAULT now() NOT NULL,
   hit_count integer DEFAULT 0 NOT NULL,
   ip character varying(15),
   user_id integer NOT NULL references users,
   effective_user_id integer,
   authenticity_token varchar(100)
);
```

### schema

```SQL
CREATE TABLE schema_update {
    version int NOT NULL
}
```

### perm_category

```SQL

CREATE SEQUENCE perm_category_id_seq;

CREATE TABLE perm_category (
    perm_category_id int PRIMARY KEY,
    description text
);
```

### perm_class

```SQL
CREATE SEQUENCE perm_class_id_seq;

CREATE TABLE perm_class (
    perm_class_id int PRIMARY KEY,
    perm_name varchar(50) NOT NULL UNIQUE,
    description text,
    perm_category_id int REFERENCES perm_category
);
```

#### perm

```SQL
CREATE SEQUENCE perm_id_seq;

CREATE TYPE perm_method AS ENUM ('READ', 'WRITE', 'APPEND');

CREATE TABLE perm (
    perm_id int PRIMARY KEY,
    perm_class_id int NOT NULL REFERENCES perm_class ON DELETE CASCADE,
    method perm_method NOT NULL,
    unique(perm_class_id, method)
);
```

### user_perm

```SQL
CREATE TABLE user_perm (
    user_id int NOT NULL REFERENCES users ON DELETE CASCADE,
    perm_id int NOT NULL REFERENCES perm ON DELETE CASCADE,
    unique(user_id, perm_id)
);
```

### param

```SQL
CREATE TABLE param (
    param_name text NOT NULL,
    param_value text
);
```

### sticky

**TO CHECK**

```SQL

CREATE TABLE sticky (
    user_id integer NOT NULL REFERENCES users,
    name varchar(255) NOT NULL,
    value varchar(255) NOT NULL,
    url varchar(255) NOT NULL
);
```

### file

```SQL
CREATE SEQUENCE file_id_seq;

CREATE TABLE file (
    file_id integer PRIMARY KEY DEFAULT nextval('file_id_seq'::regclass),
    user_id integer NOT NULL REFERENCES users,
    filename text NOT NULL,
    data bytea NOT NULL,
    upload_date timestamp without time zone DEFAULT now(),
    mime_type text NOT NULL
);

```

### file_alias_path

```SQL
CREATE TABLE file_alias_path (
    url_path text PRIMARY KEY,
    file_id int REFERENCES file(file_id) NOT NULL
);
```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[PostgreSQL docs on domains]: http://www.postgresql.org/docs/9.4/static/sql-createdomain.html
[pgcrypto module]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html
[postgresql-contrib]: http://www.postgresql.org/docs/9.4/static/contrib.html

[pgcrypto]: #pgcrypto
[Anonymous User]: #anonymous-user

[validation_messages]: #validation_messages
[session]: #session
[schema]: #schema
[sticky]: #sticky
[users]: #users
[perm_category]: #perm_category
[perm_class]: #perm_class
[perm]: #perm
[user_perm]: #user_perm
[file]: #file
[file_alias_path]: #file_alias_path