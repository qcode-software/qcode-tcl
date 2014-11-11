qc::html_info_tables
====================

part of [Docs](.)

Usage
-----
`qc::html_info_tables args`

Description
-----------
Foreach dict in args return a table with 2 columns with name value in each row

Examples
--------
```tcl

% html_info_tables {Name "Jimmy Tarbuck" Venue "Palace Ballroom"} {Name "Des O'Conner" Venue "Royal Palladium"}
<table class="columns-container">
<tbody>
<tr>
<td><table class="column">
<colgroup>
<col class="bold">
<col>
</colgroup>
<tbody>
<tr>
<td>Name</td>
<td>Jimmy Tarbuck</td>
</tr>
<tr>
<td>Venue</td>
<td>Palace Ballroom</td>
</tr>
</tbody>
</table>
</td>
<td><table class="column">
<colgroup>
<col class="bold">
<col>
</colgroup>
<tbody>
<tr>
<td>Name</td>
<td>Des O'Conner</td>
</tr>
<tr>
<td>Venue</td>
<td>Royal Palladium</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"