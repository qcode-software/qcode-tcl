Safe HTML & Markdown
====================
part of [Qcode Documentation](index.md)

"Safe" HTML and "safe" markdown are subsets of HTML and markdown meaning that some elements, attributes, and values are deemed "unsafe" to use because they could break the containing HTML/markdown or they could have malicious intent (such as scripts).

The qcode-tcl library offers ways to sanitize text such that offending elements, attributes and values are removed from the text. There are also procs provided to check if text contains unsafe elements and to return a report on any unsafe objects.

### HTML
* [`qc::is safe_html`]
* [`qc::cast safe_html`]
* [`qc::castable safe_html`]
* [`qc::html_sanitize`]
* [`qc::safe_html_error_report`]

### Markdown
* [`qc::is safe_markdown`]
* [`qc::cast safe_markdown`]
* [`qc::castable safe_markdown`]
* [`qc::commonmark2html`]

What is allowed?
----------------

### Elements

Type | Elements
|------|----------
|Headings | `h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `h7`, `h8`
|Prose |  `p`, `div`, `blockquote`
|Formatted | `pre`
| Inline | `b`, `i`, `strong`, `em`, `tt`, `code`, `ins`, `del`, `sup`, `sub`, `kbd`, `samp`, `q`, `var`
| Lists | `ol`, `ul`, `li`, `dl`, `dt`, `dd`
| Tables | `table`, `thead`, `tbody`, `tfoot`, `tr`, `td`, `th`
| Breaks | `br`, `hr`
| Ruby (East Asian) | `ruby`, `rt`, `rp`


### Attributes & Values

|Element | Attributes
|------|----------
| `a` | `href` (`http://`, `https://`, `mailto://` URI schemes and relative paths only)
| `img` | `src` (`http://` and `https://` URI schemes and relative paths only)
| `div` | `itemscope`, `itemtype`
| `code` | `class` (`language-` prefix only - to support syntax highlighting)
| All | `abbr`, `accept`, `accept-charset`, `accesskey`, `action`, `align`, `alt`, `axis`, `border`, `cellpadding`, `cellspacing`, `char`, `charoff`, `charset`, `checked`, `cite`, `clear`, `cols`, `colspan`, `color`, `compact`, `coords`, `datetime`, `dir`, `disabled`, `enctype`, `for`, `frame`, `headers`, `height`, `hreflang`, `hspace`, `ismap`, `label`, `lang`, `longdesc`, `maxlength`, `media`, `method`, `multiple`, `name`, `nohref`, `noshade`, `nowrap`, `prompt`, `readonly`, `rel`, `rev`, `rows`, `rowspan`, `rules`, `scope`, `selected`, `shape`, `size`, `span`, `start`, `summary`, `tabindex`, `target`, `title`, `type`, `usemap`, `valign`, `value`, `vspace`, `width`, `itemprop`

Additionally, any `li` without a `ol` or `ul` ancestor are considered unsafe as are any table elements (`thead`, `tbody`, `tfoot`, `tr`, `td`, `th`) that do not have a `table` ancestor.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[`qc::is safe_html`]: procs/is-safe_html.md
[`qc::cast safe_html`]: procs/cast-safe_html.md
[`qc::castable safe_html`]: procs/castable-safe_html.md
[`qc::html_sanitize`]: procs/html_sanitize.md
[`qc::safe_html_error_report`]: procs/safe_html_error_report.md
[`qc::is safe_markdown`]: procs/is-safe_markdown.md
[`qc::cast safe_markdown`]: procs/cast-safe_markdown.md
[`qc::castable safe_markdown`]: procs/castable-safe_markdown.md
[`qc::commonmark2html`]: procs/commonmark2html.md
