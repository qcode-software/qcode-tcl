qc::email_send
==============

part of [Sending Email](../email.md)

Usage
-----
`email_send from to subject text|html ?cc? ?bcc? ?reply-to? ?attachment? ?attachments? ?filename? ?filenames?
	<br><em>arguments passed in as dict</em>`

Description
-----------
Send email with plain text or html and add optional attachments

Examples
--------
```tcl

% qc::email_send from joe@bloggs.com to cool@fonzy.net subject Hi text "What's up"

% qc::email_send from {"Tom Jones" <tommy@wales.com>} to "\"The Fonz\" <cool@fonzy.net>"  cc "\"The King\" <elvis@graceland.org>" subject "Woah Woah" html "What's <i>new</i> pussy cat" 
# If html2text is installed will provide a text alternative

# Image attachment with base64 encoded data
% qc::email_send from {"Tom Jones" <tommy@wales.com>} to {"The King" <elvis@graceland.org>}  subject Hi text "The misses"  attachment [list encoding base64 data "AsgHy...Jk==" filename Priscilla.png]

#| attachments is a list of dicts
#| dict keys are encoding data filename ?cid?
#| Example dict - {encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}
#| Including cid in this dict is optional, if provided it must be world-unique
#| cid can be used to reference an attachment within the email's html.
#| eg. embed an image (<img src="cid:1312967973006309"/>).

# Image attachment used in html
% qc::email_send from {"Tom Jones" <tommy@wales.com>} to {"The King" <elvis@graceland.org>} subject Hi  html {<h2>Priscilla</h2><img src="cid:1312967973006309"/>}  attachment [list encoding base64 data "AsgHy...Jk==" filename Priscilla.png cid 1312967973006309]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"