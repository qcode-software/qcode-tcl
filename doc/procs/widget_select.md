qc::widget_select
=================

part of [Docs](.)

Usage
-----
`
	widget_select name widgetName value text options {name value name value ...} ?null_option yes/no?
    `

Description
-----------
Return an HTML form dropdown list.
    <h4>options</h4>
    The options arg is a name value list that is used to contruct the dropdown options.
    Two helper procs are:-<br>
    <proc>html_options_simple</proc><br>
    <proc>html_options_db</proc>

Examples
--------
```tcl

% widget_select name letter value &quot;&quot; options {Alpha A Bravo B Charlie C} null_option yes
&lt;select id=&quot;letter&quot; name=&quot;letter&quot;&gt;
&lt;option value=&quot;&quot;&gt;- Select -&lt;/option&gt;
&lt;option value=&quot;A&quot;&gt;Alpha&lt;/option&gt;
&lt;option value=&quot;B&quot;&gt;Bravo&lt;/option&gt;
&lt;option value=&quot;C&quot;&gt;Charlie&lt;/option&gt;
&lt;/select&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"