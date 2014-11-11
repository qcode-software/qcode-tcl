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
    <html>
    <head>
    <style type="text/css">
    body {
    font-family: Arial, Helvetica, sans-serif;
    font-size:84%;
    }
    table {font-family: Arial, Helvetica, sans-serif;font-size:100%}
    </style>
    </head>
    <body>
        <p>Hello</p>
        <table>
            <tr><td>Table entry</td></tr>
        </table>
    </body>
    </html>
    }

% qc::html_styles2inline $html
    <html>
    <head><style type="text/css">
    body {
    font-family: Arial, Helvetica, sans-serif;
    font-size:84%;
    }
    table {font-family: Arial, Helvetica, sans-serif;font-size:100%}
    </style>
    </head>
    <body style="font-family:Arial, Helvetica, sans-serif;font-size:84%">
        <p>Hello</p>
        <table style="font-family:Arial, Helvetica, sans-serif;font-size:100%">
            <tr><td>Table entry</td></tr>
        </table>
    </body>
    </html>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"