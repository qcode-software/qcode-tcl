qc::form_layout_table
=====================

part of [Docs](.)

Usage
-----
`qc::form_layout_table args`

Description
-----------
Construct an html table with 2 columns for labels and form elements

Examples
--------
```tcl

    % set conf {
        {name firstname value {} label Firstname width 200}
        {name surname value {} label Surname width 250}
        {name email value {} label Email id email_address}
        {name color value &quot;&quot; label Colour type select options {1 Red 2 Blue 3 Green}}
        {name agree value no type checkbox label Agree}
    }
    % qc::form_layout_table $conf
&lt;table class=&quot;form-layout-table&quot;&gt;
&lt;colgroup&gt;
&lt;col class=&quot;label&quot;&gt;
&lt;col&gt;
&lt;/colgroup&gt;
&lt;tbody&gt;
&lt;tr&gt;
&lt;td&gt;&lt;label for=&quot;firstname&quot;&gt;Firstname&lt;/label&gt;&lt;/td&gt;
&lt;td&gt;&lt;input style=&quot;width:200px&quot; id=&quot;firstname&quot; name=&quot;firstname&quot; value=&quot;&quot; type=&quot;text&quot; sticky=&quot;no&quot;&gt;&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;&lt;label for=&quot;surname&quot;&gt;Surname&lt;/label&gt;&lt;/td&gt;
&lt;td&gt;&lt;input style=&quot;width:250px&quot; id=&quot;surname&quot; name=&quot;surname&quot; value=&quot;&quot; type=&quot;text&quot; sticky=&quot;no&quot;&gt;&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;&lt;label for=&quot;email_address&quot;&gt;Email&lt;/label&gt;&lt;/td&gt;
&lt;td&gt;&lt;input style=&quot;width:160px&quot; name=&quot;email&quot; value=&quot;&quot; id=&quot;email_address&quot; type=&quot;text&quot; sticky=&quot;no&quot;&gt;&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;&lt;label for=&quot;color&quot;&gt;Colour&lt;/label&gt;&lt;/td&gt;
&lt;td&gt;&lt;select id=&quot;color&quot; name=&quot;color&quot; sticky=&quot;no&quot;&gt;
&lt;option value=&quot;Red&quot;&gt;1&lt;/option&gt;
&lt;option value=&quot;Blue&quot;&gt;2&lt;/option&gt;
&lt;option value=&quot;Green&quot;&gt;3&lt;/option&gt;
&lt;/select&gt;
&lt;/td&gt;
&lt;/tr&gt;
&lt;tr&gt;
&lt;td&gt;&lt;/td&gt;
&lt;td&gt;&lt;input id=&quot;agree&quot; name=&quot;agree&quot; value=&quot;no&quot; type=&quot;checkbox&quot; sticky=&quot;no&quot;&gt; &lt;label for=&quot;agree&quot;&gt;Agree&lt;/label&gt;&lt;/td&gt;
&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"