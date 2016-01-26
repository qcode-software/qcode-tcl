Connection Response API
===================
part of [Qcode Documentation](index.md)

* * *

This describes the API is for modifying the [connection response].

### Status

* [valid](procs/response_status_valid.md)
* [invalid](procs/response_status_invalid.md)
* [get](procs/response_status_get.md)

### Record

* [valid]
* [invalid]
* [remove]
* [all_valid]
* [sensitive]

### Message

* [notify]
* [alert]
* [error]

### Action

* [redirect]
* [resubmit]

### Extending The Response

* [extend]

## Response Formats

The following procs will format the response ready for returning to the client:

* [response2json]
* [response2xml]
* [response2html]

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[valid]: procs/response_record_valid.md
[invalid]: procs/response_record_invalid.md
[remove]: procs/response_record_remove.md
[all_valid]: procs/response_record_all_valid.md
[sensitive]: procs/response_record_sensitive.md
[notify]: procs/response_message_notify.md
[alert]: procs/response_message_alert.md
[error]: procs/response_message_error.md
[redirect]: procs/response_action_redirect.md
[resubmit]: procs/response_action_resubmit.md
[extend]: procs/response_extend.md

[response2json]: procs/response2json.md
[response2xml]: procs/response2xml.md
[response2html]: procs/response2html.md

[connection response]: connection-response.md
