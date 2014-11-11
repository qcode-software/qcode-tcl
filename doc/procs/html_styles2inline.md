qc::html_styles2inline
======================

part of [Docs](.)

Usage
-----
`qc::html_styles2inline html`

Description
-----------
Applies defined styles in html head as inline styles for relevant elements in body

Examples
--------
```tcl

    % set html {
    &lt;html&gt;
    &lt;head&gt;
    &lt;style type=&quot;text/css&quot;&gt;
    body {
    font-family: Arial, Helvetica, sans-serif;
    font-size:84%;
    }
    table {font-family: Arial, Helvetica, sans-serif;font-size:100%}
    &lt;/style&gt;
    &lt;/head&gt;
    &lt;body&gt;
        &lt;p&gt;Hello&lt;/p&gt;
        &lt;table&gt;
            &lt;tr&gt;&lt;td&gt;Table entry&lt;/td&gt;&lt;/tr&gt;
        &lt;/table&gt;
    &lt;/body&gt;
    &lt;/html&gt;
    }

% qc::html_styles2inline $html
    &lt;html&gt;
    &lt;head&gt;&lt;style type=&quot;text/css&quot;&gt;
    body {
    font-family: Arial, Helvetica, sans-serif;
    font-size:84%;
    }
    table {font-family: Arial, Helvetica, sans-serif;font-size:100%}
    &lt;/style&gt;
    &lt;/head&gt;
    &lt;body style=&quot;font-family:Arial, Helvetica, sans-serif;font-size:84%&quot;&gt;
        &lt;p&gt;Hello&lt;/p&gt;
        &lt;table style=&quot;font-family:Arial, Helvetica, sans-serif;font-size:100%&quot;&gt;
            &lt;tr&gt;&lt;td&gt;Table entry&lt;/td&gt;&lt;/tr&gt;
        &lt;/table&gt;
    &lt;/body&gt;
    &lt;/html&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"