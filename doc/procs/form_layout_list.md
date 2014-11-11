qc::form_layout_list
====================

part of [Docs](.)

Usage
-----
`qc::form_layout_list conf`

Description
-----------
Layout the form elements in the conf with input elements below labels.

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
    % qc::form_layout_list $conf
&lt;div style=&quot;padding-bottom:1em;&quot;&gt;&lt;label for=&quot;firstname&quot;&gt;Firstname&lt;/label&gt;&lt;br&gt;&lt;input style=&quot;width:200px&quot; id=&quot;firstname&quot; name=&quot;firstname&quot; value=&quot;&quot; type=&quot;text&quot;&gt;&lt;/div&gt;&lt;div style=&quot;padding-bottom:1em;&quot;&gt;&lt;label for=&quot;surname&quot;&gt;Surname&lt;/label&gt;&lt;br&gt;&lt;input style=&quot;width:250px&quot; id=&quot;surname&quot; name=&quot;surname&quot; value=&quot;&quot; type=&quot;text&quot;&gt;&lt;/div&gt;&lt;div style=&quot;padding-bottom:1em;&quot;&gt;&lt;label for=&quot;email_address&quot;&gt;Email&lt;/label&gt;&lt;br&gt;&lt;input style=&quot;width:160px&quot; name=&quot;email&quot; value=&quot;&quot; id=&quot;email_address&quot; type=&quot;text&quot;&gt;&lt;/div&gt;&lt;div style=&quot;padding-bottom:1em;&quot;&gt;&lt;label for=&quot;color&quot;&gt;Colour&lt;/label&gt;&lt;br&gt;&lt;select id=&quot;color&quot; name=&quot;color&quot;&gt;
&lt;option value=&quot;Red&quot;&gt;1&lt;/option&gt;
&lt;option value=&quot;Blue&quot;&gt;2&lt;/option&gt;
&lt;option value=&quot;Green&quot;&gt;3&lt;/option&gt;
&lt;/select&gt;
&lt;/div&gt;&lt;div style=&quot;padding-bottom:1em;&quot;&gt;&lt;input id=&quot;agree&quot; name=&quot;agree&quot; value=&quot;no&quot; type=&quot;checkbox&quot;&gt; &lt;label for=&quot;agree&quot;&gt;Agree&lt;/label&gt;&lt;/div&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"