# Sending Email
Requires an MTA listening locally on port 25. 

[email_send](procs/email_send.md)

Examples
--------------------------

	
	email_send from jane@acme.com to john@nasa.com subject Hello text "Hi Jimmy, what's up"
	
	
	email_send from "Jane Doe <jane@acme.com>" to "John Whyte <john@nasa.com>" subject Hello html "Hi Jimmy, <em>what's up</em>"
	
	
	email_send from jane@acme.com to john@nasa.com cc the_boss@acme.com subject Help text "I'm screwed!"
	

### Attachments
The arg attachments is a list of dicts.
The dict keys are one of `encoding, data, filename, ?cid?`

Example dict - `{encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}`

Including a cid in this dict is optional, if provided it must be world-unique.
The cid can be used to reference an attachment within the email's html.

eg. embed an image (<img src="cid:1312967973006309"/>).



	
	email_send from "Jane Doe <jane@acme.com>" to "John Whyte <john@nasa.com>" subject Hello \
	    text "Hi Jimmy, what's up" attachment [encoding base64 data aGVsbG8= filename attach1.pdf](list)
	
	
	email_send from "Jane Doe <jane@acme.com>" to "John Whyte <john@nasa.com>" subject Hello \
	    html "Hi Jimmy, <em>what's up</em> <img src='cid:1312967973006309'/>" attachment [encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf](list)
	
	
	email_send from "Jane Doe <jane@acme.com>" to "John Whyte <john@nasa.com>" subject Hello \
	    html "Hi Jimmy, <em>what's up</em>" filename /home/jane/nasa/rocket.jpg
	

