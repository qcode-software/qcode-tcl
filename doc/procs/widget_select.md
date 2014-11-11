qc::widget_select
=================

part of [Docs](../index.md)

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

% widget_select name letter value "" options {Alpha A Bravo B Charlie C} null_option yes
<select id="letter" name="letter">
<option value="">- Select -</option>
<option value="A">Alpha</option>
<option value="B">Bravo</option>
<option value="C">Charlie</option>
</select>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"