Data Model Dependencies
=======================
part of [Qcode Documentation](index.md)

* * *

Certain parts of the qcode-tcl library are dependent upon a data model being in place and other parts depend upon specific tables existing. Below are the procs and their dependents along with the SQL statements to add the data model dependency.


Procs & Data Model Dependencies
-------------------------------

Proc | Table(s)
-----|---------
| `qc::validate2model` | [validation_messages]
| `qc::handlers validate2model` | [validation_messages]
| `qc::filter_validate` | [validation_messages]
| `qc::session_new` | session
| `qc::session_authenticity_token` | session
| `qc::session_update` |  session
| `qc::session_sudo_logout` | session
| `qc::session_kill` | session
| `qc::session_exists` | session
| `qc::session_valid` | session
| `qc::session_user_id` | session
| `qc::session_sudo` | session
| `qc::session_purge` | session
| `qc::anonymous_session_id` | session
| `qc::schema_update` | schema
| `qc::sticky_set` | sticky
| `qc::sticky_save` | sticky
| `qc::sticky_get` | sticky
| `qc::sticky_exists` | sticky

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
    firstname plain_string NOT NULL,
    surname plain_string NOT NULL,
    email plain_string NOT NULL,
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

### Permissons

#### perm_category

```SQL

CREATE SEQUENCE perm_category_id_seq;

CREATE TABLE perm_category (
    perm_category_id int PRIMARY KEY,
    description text
);
```

#### perm_class

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

#### user_perm

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

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[PostgreSQL docs on domains]: http://www.postgresql.org/docs/9.4/static/sql-createdomain.html
[validation_messages]: #validation_messages