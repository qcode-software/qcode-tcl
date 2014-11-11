qc::widget
==========

part of [Docs](.)

Usage
-----
`
	widget name widgetName label labelText ?required yes?
    `

Description
-----------
Look for a proc "widget_$type" to make the widget

Examples
--------
```tcl

% qc::widget type text name textWidget value &quot;Horses&quot; tooltip &quot;This is a tooltip&quot;
&lt;input style=&quot;width:160px&quot; id=&quot;textWidget&quot; value=&quot;Horses&quot; name=&quot;textWidget&quot; type=&quot;text&quot; title=&quot;This is a tooltip&quot;&gt;

% qc::widget type label name labelWidget label &quot;This is a label&quot; tooltip &quot;This is a tooltip&quot;
&lt;label for=&quot;labelWidget&quot; title=&quot;This is a tooltip&quot;&gt;This is a label&lt;/label&gt;

% qc::widget type quantum name quantumWidget value &quot;Everything&quot; 
No widget proc defined for quantum
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"