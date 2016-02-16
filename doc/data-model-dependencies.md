Data Model Dependencies
=======================
part of [Qcode Documentation](index.md)

* * *

Certain parts of the qcode-tcl library are dependent upon a data model being in place and other parts depend upon specific tables existing. Below are the procs and their dependents along with the SQL statements to add the data model dependency.

**Note:** `?` wrapped around table names means that there's only a partial dependency and may not be necessary depending on input or other circumstances.


Procs & Data Model Dependencies
-------------------------------

Proc | Table(s) | Other
-----|----------|------
| `qc::validate2model` | [validation_messages] | 
| `qc::handlers validate2model` | [validation_messages] | 
| `qc::filter_validate` | [validation_messages] |
| `qc::filter_authenticate` | [session], [users] | [Anonymous User]
| `qc::filter_file_alias_path` | [file], [file_alias_path] |
| `qc::file_alias_path_exists` | [file], [file_alias_path] |
| `qc::file_alias_path2file_id` | [file], [file_alias_path] |
| `qc::file_alias_path_new` | [file], [file_alias_path] |
| `qc::file_alias_path_update` | [file], [file_alias_path]
| `qc::file_alias_path_delete` | [file], [file_alias_path] |
| `qc::handler_db_files` | [file], [image] | 
| `qc::password_hash` |  | [pgcrypto]
| `qc::session_new` | [session], [users] |
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
| `qc::auth` | [session], [users] |
| `qc::auth_check` | [session], [users] |
| `qc::auth_hba` | [users] |
| `qc::auth_hba_check` | [users] |
| `qc::auth_session` | [session], [users] |
| `qc::db_file_insert` | [file], ?[session], [users]? |
| `qc::db_file_copy` | [file] |
| `qc::db_file_export` | [file] |
| `qc::db_file_upload` | [file], ?[image]?, ?[session], [users]? |
| `qc::plupload.html` | [file], ?[image]? |
| `qc::file_upload` | [session], [users] |
| `qc::file_handler` | [file] |
| `qc::file_cache_create` | [file] |
| `qc::file_data` | [file] |
| `qc::image_resize` | [file] |
| `qc::image_cache_create` | [file] |
| `qc::image_data` | [file] |
| `qc::image_handler` | [file] |
| `qc::schema_update` | [schema] | 
| `qc::sticky_set` | [sticky], [session], [users] | 
| `qc::sticky_save` | [sticky], [session], [users] | 
| `qc::sticky_get` | [sticky], [session], [users] | 
| `qc::sticky_exists` | [sticky], [session], [users] |
| `qc::sticky2vars` | [sticky], [session], [users] |
| `qc::sticky_default` | [sticky], [session], [users] |
| `qc::widget` | ?[sticky], [session], [users]? |
| `qc::widget_text` | ?[sticky], [session], [users]? |
| `qc::widget_compare` | ?[sticky], [session], [users]? |
| `qc::widget_combo` | ?[sticky], [session], [users]? |
| `qc::widget_htmlarea` | ?[sticky], [session], [users]? |
| `qc::widget_textarea` | ?[sticky], [session], [users]? |
| `qc::widget_select` | ?[sticky], [session], [users]? |
| `qc::widget_password` | ?[sticky], [session], [users]? |
| `qc::widget_bool` | ?[sticky], [session], [users]? |
| `qc::widget_radiogroup` | ?[sticky], [session], [users]? |
| `qc::widget_image_combo` | ?[sticky], [session], [users]? |
| `qc::columns_show_hide_toolbar` | ?[sticky], [session], [users]? |
| `qc::form_layout_table` | ?[sticky], [session], [users]? |
| `qc::form_layout_tables` | ?[sticky], [session], [users]? |
| `qc::form_layout_tbody` | ?[sticky], [session], [users]? |
| `qc::form_layout_list` | ?[sticky], [session], [users]? | 
| `qc::param_get` | [param] | 
| `qc::param_set` | [param] | 
| `qc::param_exists` | [param] |
| `qc::db_validation_message` | [validation_messages] |
| `qc::form` | ?[session], [users]? | 
| `qc::form_authenticity_token` | [session], [users] |
| `qc::perm_set` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perm_test_user` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perm_test` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perm` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perms` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perm_if` | [perm], [perm_category], [perm_class], [user_perm], [users] |
| `qc::perm_category_add` | [perm_category] |
| `qc::perm_add` | [perm], [perm_category], [perm_class] |

#### pgcrypto

The [pgcrypto module] for PostgreSQL provides cryptographic functions - some of which are used by procs in the library. In order to install the pgcrypto extension the [postgresql-contrib] package will need to be installed first.


```SQL
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION sha1(bytea) returns text AS $$
    SELECT encode(digest($1, 'sha1'), 'hex')
$$ LANGUAGE SQL STRICT IMMUTABLE;
```

#### Anonymous User

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

#### validation_messages

```SQL
CREATE TABLE validation_messages (
    table_name text NOT NULL,
    column_name text NOT NULL,
    message varchar(255) NOT NULL
);
```

#### users

```SQL
CREATE TYPE user_state AS ENUM ('ACTIVE', 'DISABLED');

CREATE SEQUENCE user_id_seq;

CREATE TABLE users (
    user_id int PRIMARY KEY,
    firstname varchar(255) NOT NULL,
    surname varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    password_hash varchar(60) NOT NULL,
    user_state user_state NOT NULL DEFAULT 'ACTIVE',
    ip varchar(15)
);
```

#### session

```SQL
CREATE TABLE session (
   session_id text PRIMARY KEY,
   time_created timestamp(0) WITHOUT time zone DEFAULT now() NOT NULL,
   time_modified timestamp(0) WITHOUT time zone DEFAULT now() NOT NULL,
   hit_count integer DEFAULT 0 NOT NULL,
   ip varchar(15),
   user_id integer NOT NULL REFERENCES users,
   effective_user_id integer,
   authenticity_token varchar(100)
);
```

#### schema

```SQL
CREATE TABLE schema {
    version int NOT NULL
}
```

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

#### param

```SQL
CREATE TABLE param (
    param_name varchar(50) PRIMARY KEY,
    param_value text
);
```

#### sticky

```SQL
CREATE TABLE sticky (
    user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name varchar(255),
    value varchar(255) ,
    url varchar(255)
);
```

#### file

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

#### file_alias_path

```SQL
CREATE TABLE file_alias_path (
    url_path text PRIMARY KEY,
    file_id int REFERENCES file(file_id) NOT NULL
);
```

#### image

```SQL
CREATE TABLE image (
    file_id int PRIMARY KEY REFERENCES file ON DELETE CASCADE,
    width int,
    height int
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
[param]: #param
[perm_category]: #perm_category
[perm_class]: #perm_class
[perm]: #perm
[user_perm]: #user_perm
[file]: #file
[file_alias_path]: #file_alias_path
[image]: #image
