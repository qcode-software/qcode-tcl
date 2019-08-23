How to Define a New Data Type (Domain)
================================

Where possible define data types within the data model, so that PostgreSQL can perform the necessary validation.
New data types can be defined in Postgresql using domains and enumerations.

The ensembles [is, cast and castable](https://github.com/qcode-software/qcode-tcl/blob/master/doc/data-types.md) will automatically
check the data model against the model.
So for example, the command ``` qc::is plain_text ``` can only exist if the domain plain_text has been defined in the data model. 

Because validation of the data model is ultimately handled by the castable ensemble, no additional tcl code needs to be written to 
handle validation of domains and enumerations.  

Example
------------

We will examine the creation of a table called `blog_posts` with a column called `blog_post_url_segment`.


```sql
CREATE OR REPLACE FUNCTION is_blog_url_segment(text)
	    returns boolean as $$
	    select $1 ~ '^[a-z0-9\-]*$';
	    $$ language sql immutable strict;

	    create domain blog_url_segment as text
	    check(
		  is_blog_url_segment(value)
		  );
```
The code above first creates a postgreSQL function called `is_blog_url_segment(text)` which uses a regular expression to test 
whether a string contains only lowercase letters, numbers and dashes.
The code then creates a domain called `blog_url_segment`, which uses the newly created function as a check constraint. 

The new type can be used when creating a new table as shown below

```sql

create table blog_posts (
			 blog_post_id int primary key,
			 blog_post_title plain_string,
			 blog_post_url_segment blog_url_segment unique not null,
			 blog_post_content text
			 );

```

Customised error messages can be created using the validation_messages table. 

```sql

insert into validation_messages(
					table_name, 
					column_name, 
					message
					)
	values (
		'blog_posts', 
		'blog_post_url_segment', 
		'URL segment can only contain lowercase letters, numbers and dashes.'
		); 
```
