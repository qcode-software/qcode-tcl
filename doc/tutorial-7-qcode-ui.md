Tutorial 7: Validation with qcode-ui
========
part of [Qcode Documentation](index.md)

-----
### Adding qcode-ui

Amend your form html code to include a `<head>` element with calls to the requisite libraries and to instantiate the AJAX validation, as follows:

```html
<html>
    <head>
        <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"></script>
        <script src="https://js.qcode.co.uk/vendor/js-cookie/1.5.1/js-cookie.min.js"></script>
        <script src="http://cdn.jsdelivr.net/qtip2/2.2.1/jquery.qtip.min.js"></script>
        <script src="https://js.qcode.co.uk/qcode-ui-4.9.0/js/qcode-ui.js"></script>

        <link rel="stylesheet" href="http://cdn.jsdelivr.net/qtip2/2.2.1/jquery.qtip.min.css">
        <link rel="stylesheet" href="https://js.qcode.co.uk/qcode-ui-4.9.0/css/qcode-ui.css">
    </head>

    <body>

        <form method="POST" id="form_person" action="form_process">
            First Name <input name="first_name" type="text" />
            Last Name  <input name="last_name" type="text" />
            <input type="submit" name="submit" value="submit" />
        </form>

        <script>
            $(function() {
                // Register validation plugin
                $('#form_person').validation({
              qtip: {
                  // customise style and position of qtip
                  position: {
                my: 'right center',
                at: 'right center',
                viewport: $(window),
                adjust: {
                    method: 'shift',
                    x: -10
                },
                effect: false
                  },
                  style: {
                tip: {
                    corner: false
                }
                  }
              },
              messages: {
                  // position of form notification
                  error: {
                before: '#form_person'
                  },
                  alert: {
                before: '#form_person'
                  },
                  notify: {
                before: '#form_person'
                  }
              }
                });
            });
        </script>

    </body>
</html>
```

You will also need to amend the `register POST /form_process` proc, removing the line 
`ns_returnredirect [qc::url form_results.html id $person_id]` and replacing it with the following:

```
qc::response action redirect [qc::url form_results.html person_id $person_id]
return [qc::return_response]
```

Submitting the form with non valid information will now provide an error message via AJAX above the form instead of the unformatted message as previously displayed.
