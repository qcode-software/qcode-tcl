Title: Date Handling
CSS: default.css

Date Handling
======================
part of [Qcode Documentation](index.md)

* * *

Date Representation
--------------------------


Dates in qcode are represented using a limited ISO 8601 format of YYYY-MM-DD.

This format matches the default postgresql *date* data type and should be unambiguous.

Testing if a string is a valid date is done using [is_date].

Parsing Date Strings
--------------------------

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

Date Calculations
--------------------------
Tcl does a great job of parsing strings to carry out simple date calculations.

<pre class="tcl example">
% cast_date "2007-06-05 + 3days"
2007-06-08
%
% cast_date "2007-06-05 - 2 months"
2007-04-05
</pre>

Date Helpers
--------------------------

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

Formatting Dates
--------------------------

Tcl provides a rich set of features to format dates but here are a few useful shortcuts.

* [format_date]
* [format_date_iso]
* [format_date_letter]
* [format_date_rel]
* [format_date_uk]
* [format_date_uk_long]

* * *

[is_date]: procs/is_date.md
[cast_date]: procs/cast_date.md
[cast_epoch]: procs/cast_epoch.md

[date_compare]: procs/date_compare.md
[date_day_name]: procs/date_day_name.md
[date_day_shortname]: procs/date_day_shortname.md
[date_dom]: procs/date_dom.md

[date_month]: procs/date_month.md
[date_month_name]: procs/date_month_name.md
[date_month_shortname]: procs/date_month_shortname.md
[date_month_start]: procs/date_month_start.md
[date_month_end]: procs/date_month_end.md

[date_quarter]: procs/date_quarter.md
[date_quarter_start]: procs/date_quarter_start.md
[date_quarter_end]: procs/date_quarter_end.md

[date_year]: procs/date_year.md

[date_year_start]: procs/date_year_start.md
[date_year_end]: procs/date_year_end.md

[date_year_iso_start]: procs/date_year_iso_start.md
[date_year_iso_end]: procs/date_year_iso_end.md


[dates]: procs/dates.md
[format_date]: procs/format_date.md
[format_date_iso]: procs/format_date_iso.md
[format_date_letter]: procs/format_date_letter.md
[format_date_rel]: procs/format_date_rel.md
[format_date_uk]: procs/format_date_uk.md
[format_date_uk_long]: procs/format_date_uk_long.md
