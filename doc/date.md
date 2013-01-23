Title: Date Handling
CSS: default.css

# Date Handling
part of [Qcode Documentation](../index.html)

* * *

## Date Representation

Dates in qcode are represented using a limited ISO 8601 format of YYYY-MM-DD.

This format matches the default postgresql *date* data type and should be unambiguous.

Testing if a string is a valid date is done using [is_date].

## Parsing Date Strings
The proc [cast_date] will try to convert a wide variety of date strings into an ISO date.

<pre class="tcl example">
% cast_date 12/5/07
2007-05-12
# At present dates in this format are assumed to be European DD/MM/YY
%
% cast_date yesterday
2007-05-11
%
% cast_date "June 23rd"
2007-06-23
</pre>

The proc [cast_epoch] does the real work of parsing date strings into a [unix epoch](http://en.wikipedia.org/wiki/Unix_time)

## Date Calculations
Tcl does a great job of parsing strings to carry out simple date calculations.

<pre class="tcl example">
% cast_date "2007-06-05 + 3days"
2007-06-08
%
% cast_date "2007-06-05 - 2 months"
2007-04-05
</pre>

## Date Helpers

* [date_compare]
* [date_day_name]
* [date_day_shortname]
* [date_dom]

### Month

* [date_month]
* [date_month_name]
* [date_month_shortname]
* [date_month_start]
* [date_month_end]

### Quarter

* [date_quarter]
* [date_quarter_start]
* [date_quarter_end]

### Year

* [date_year]
* [date_year_start]
* [date_year_end]
* [date_year_iso_start]
* [date_year_iso_end]
* [dates]

## Formatting Dates

Tcl provides a rich set of features to format dates but here are a few useful shortcuts.

* [format_date]
* [format_date_iso]
* [format_date_letter]
* [format_date_rel]
* [format_date_uk]
* [format_date_uk_long]

* * *

[is_date]: qc/is_date.html
[cast_date]: qc/cast_date.html
[cast_epoch]: qc/cast_epoch.html

[date_compare]: qc/date_compare.html
[date_day_name]: qc/date_day_name.html
[date_day_shortname]: qc/date_day_shortname.html
[date_dom]: qc/date_dom.html

[date_month]: qc/date_month.html
[date_month_name]: qc/date_month_name.html
[date_month_shortname]: qc/date_month_shortname.html
[date_month_start]: qc/date_month_start.html
[date_month_end]: qc/date_month_end.html

[date_quarter]: qc/date_quarter.html
[date_quarter_start]: qc/date_quarter_start.html
[date_quarter_end]: qc/date_quarter_end.html

[date_year]: qc/date_year.html

[date_year_start]: qc/date_year_start.html
[date_year_end]: qc/date_year_end.html

[date_year_iso_start]: qc/date_year_iso_start.html
[date_year_iso_end]: qc/date_year_iso_end.html


[dates]: qc/dates.html
[format_date]: qc/format_date.html
[format_date_iso]: qc/format_date_iso.html
[format_date_letter]: qc/format_date_letter.html
[format_date_rel]: qc/format_date_rel.html
[format_date_uk]: qc/format_date_uk.html
[format_date_uk_long]: qc/format_date_uk_long.html
