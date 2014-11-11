qc::email_send
==============

part of [Sending Email](../qc/wiki/SendingEmail)

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

% qc::email_send from joe@bloggs.com to cool@fonzy.net subject Hi text &quot;What&#39;s up&quot;

% qc::email_send from {&quot;Tom Jones&quot; &lt;tommy@wales.com&gt;} to &quot;\&quot;The Fonz\&quot; &lt;cool@fonzy.net&gt;&quot;  cc &quot;\&quot;The King\&quot; &lt;elvis@graceland.org&gt;&quot; subject &quot;Woah Woah&quot; html &quot;What&#39;s &lt;i&gt;new&lt;/i&gt; pussy cat&quot; 
# If html2text is installed will provide a text alternative

# Image attachment with base64 encoded data
% qc::email_send from {&quot;Tom Jones&quot; &lt;tommy@wales.com&gt;} to {&quot;The King&quot; &lt;elvis@graceland.org&gt;}  subject Hi text &quot;The misses&quot;  attachment [list encoding base64 data &quot;AsgHy...Jk==&quot; filename Priscilla.png]

#| attachments is a list of dicts
#| dict keys are encoding data filename ?cid?
#| Example dict - {encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}
#| Including cid in this dict is optional, if provided it must be world-unique
#| cid can be used to reference an attachment within the email&#39;s html.
#| eg. embed an image (&lt;img src=&quot;cid:1312967973006309&quot;/&gt;).

# Image attachment used in html
% qc::email_send from {&quot;Tom Jones&quot; &lt;tommy@wales.com&gt;} to {&quot;The King&quot; &lt;elvis@graceland.org&gt;} subject Hi  html {&lt;h2&gt;Priscilla&lt;/h2&gt;&lt;img src=&quot;cid:1312967973006309&quot;/&gt;}  attachment [list encoding base64 data &quot;AsgHy...Jk==&quot; filename Priscilla.png cid 1312967973006309]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"