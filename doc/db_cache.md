The procs 
<ul>
  <li><proc>db_cache_1row</proc>
  <li><proc>db_cache_0or1row</proc>
  <li><proc>db_cache_foreach</proc> and
  <li><proc>db_cache_select_table</proc>
</ul>
provide a database cache by storing results of executed queries in either a time limited ns_cache cache (if a ttl is specified), or a global array which will persist for the life of the thread (if no ttl is specified). A hash of each qry used as the index.<br>
Each time a cached proc is called, it checks to see if cached results exist. If the cached results exist then it returns the cached results rather than going to fetch a fresh copy from the database.

The cached version of db procs can give speed improvements where the same query is executed repeatedly but at the expense of more memory usage. The operating system may already cache parts of the filesystem and the database may cache some query results.      
