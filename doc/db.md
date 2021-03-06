Title: Qcode Database API
CSS: default.css

Qcode Database API
======================

part of [Qcode Documentation](index.md)

* * *

### SELECT statements
* [db_1row]
* [db_0or1row] and
* [db_foreach].
* [db_select_table].

### INSERT, UPDATE and other DML statements
* [db_dml]

### Database Transactions
* [db_trans]

### Sequences
* [db_seq]

### Bind Variables and Quoting
* [db_qry_parse]
* [db_quote]

### SQL Shortcuts

* [sql_set]
* [sql_insert]
* [sql_sort]

### SQL WHERE helpers

* [sql_where]
* [sql_where_cols_start]
* [sql_where_col_starts]
* [sql_where_like]
* [sql_where_in]
* [sql_where_in_not]

### Database Introspection

* [db_column_exists]
* [db_table_columns]
* [db_table_column_exists]
* [db_column_table]
* [db_qualified_table_column]
* [db_column_table_primary_exists]
* [db_column_table_primary]
* [db_column_type]
* [db_table_column_types]
* [db_column_nullable]
* [db_enum_values]
* [db_enum_exists]
* [db_domain_exists]
* [db_domain_constraint]
* [db_column_constraints]
* [db_eval_constraint]
* [db_eval_domain_constraint]
* [db_eval_column_constraints]
* [db_domain_base_type]
* [db_canonical_type]
* [db_validation_message]
* [db_sequence_exists]
* [db_owner]
* [db_database_name]
* [db_user]
* [db_extension_exists]
* [db_user_is_superuser]

### Database Initialisation
* [db_init]

---

Examples
--------------------------
Lets say we have a table users
<pre class="tcl example">
% CREATE table users (
    user_id integer primary key,
    name varchar(50),
    email varchar(100),
    password varchar(50)
);
        NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "users_pkey" for table "users"
        CREATE TABLE
% 
% insert into users (user_id,name,email,password) values (1,'Jimmy','jimmy@tarbuck.com','buz99');
% insert into users (user_id,name,email,password) values (2,'Des','des@oconner.com','conner23');
</pre>

### Getting Data Out
The Database API sets local variables with names corresponding to the column names in the query.

<pre class="tcl example">
% db_1row {select name,email from users where user_id=1}
% set name
Jimmy
% set email
jimmy@foo.com
</pre>

### Bind Variables
Bind Variables are designed to prevent ["SQL Injection Attacks"](sqlinjection.md) and escape strings ready for the database.

Bind Variables are denoted by a colon followed by the name of the variable to be substituted e.g. `:foo or :bar`.The syntax is similar to ACS and http://www.openacs.org. Postgresql's psql program also uses this notation for substitution but without escaping values.

The work is done by [db_qry_parse] but it should not be neccessary to call this proc directly.

<pre class="tcl example">
% set user_id 1
% set qry {select name from users where user_id=:user_id}
% db_qry_parse $qry
select name from users where user_id=1
</pre>

The procs [db_1row], [db_0or1row], [db_foreach],  [db_select_table] and [db_dml] all parse queries for bind variables before executing the query.

For example:-
<pre class="tcl example">
% set user_id 1
% db_1row {select name from users where user_id=:user_id}
% set name
Jimmy
</pre>

### Getting Data In
Lets say we have a sequence called user_id_seq to generate user_id numbers and we have a new user to add to the users table.

The shortcut [sql_insert] provides a concise way of constructing an INSERT [db_dml] statement.

<pre class="tcl example">
% set user_id [db_seq user_id_seq]
% set name Bob
% set email bob@monkhouse.com
% set password joker
%
% set qry "insert into users [sql_insert user_id name email password]"
insert into users (user_id,name,email,password) values (:user_id,:name,:email,:password)
%
% # So we can write
% db_dml "insert into users [sql_insert user_id name email password]"
</pre>

### Updates

Another useful shortcut for update statements is [sql_set]
Lets say we want to update user # 3  
<pre class="tcl example">
% set user_id 3
% set name "Bob Monkhouse"
% set email "\"Bob Monkhouse\" <bob@monkhouse.com>"
%
% set qry "update users set [sql_set name email] where user_id=:user_id"
update users set name=:name,email=:email where user_id=3
% 
% # Shortcut form can be handed to db_dml
% db_dml "update users set [sql_set name email] where user_id=:user_id"
</pre>

***

Qcode Software Limited <http://www.qcode.co.uk>

[db_1row]: procs/db_1row.md
[db_0or1row]: procs/db_0or1row.md 
[db_foreach]: procs/db_foreach.md
[db_select_table]: procs/db_select_table.md
[db_dml]: procs/db_dml.md
[db_trans]: procs/db_trans.md 
[db_seq]: procs/db_seq.md 
[db_qry_parse]: procs/db_qry_parse.md 
[db_quote]: procs/db_quote.md 
[sql_set]: procs/sql_set.md 
[sql_insert]: procs/sql_insert.md 
[sql_sort]: procs/sql_sort.md 
[sql_where]: procs/sql_where.md 
[sql_where_cols_start]: procs/sql_where_cols_start.md 
[sql_where_col_starts]: procs/sql_where_col_starts.md 
[sql_where_like]: procs/sql_where_like.md 
[sql_where_in]: procs/sql_where_in.md 
[sql_where_in_not]: procs/sql_where_in_not.md 
[db_column_exists]: procs/db_column_exists.md
[db_table_columns]: procs/db_table_columns.md
[db_table_column_exists]: procs/db_table_column_exists.md
[db_column_table]: procs/db_column_table.md
[db_qualified_table_column]: procs/db_qualified_table_column.md
[db_column_table_primary_exists]: procs/db_column_table_primary_exists.md
[db_column_table_primary]: procs/db_column_table_primary.md
[db_column_type]: procs/db_column_type.md
[db_table_column_types]: procs/db_table_column_types.md
[db_column_nullable]: procs/db_column_nullable.md
[db_enum_values]: procs/db_enum_values.md
[db_enum_exists]: procs/db_enum_exists.md
[db_domain_exists]: procs/db_domain_exists.md
[db_domain_constraint]: procs/db_domain_constraint.md
[db_column_constraints]: procs/db_column_constraints.md
[db_eval_constraint]: procs/db_eval_constraint.md
[db_eval_domain_constraint]: procs/db_eval_domain_constraint.md
[db_eval_column_constraints]: procs/db_eval_column_constraints.md
[db_domain_base_type]: procs/db_domain_base_type.md
[db_canonical_type]: procs/db_canonical_type.md
[db_validation_message]: procs/db_validation_message.md
[db_sequence_exists]: procs/db_sequence_exists.md
[db_owner]: procs/db_owner.md
[db_database_name]: procs/db_database_name.md
[db_user]: procs/db_user.md
[db_extension_exists]: procs/db_extension_exists.md
[db_user_is_superuser]: procs/db_user_is_superuser.md
[db_init]: procs/db_init.md
