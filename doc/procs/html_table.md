qc::html_table
==============

part of [Docs](.)

Usage
-----
`
	html_table ?dict?<br>
	html_table ~ varName varName varName ...
    `

Description
-----------
Create an HTML table.<br>
    Some options have special meaning:-

    <h3>cols</h3>
    <div class="indent">
    cols is a list of col dicts.Each dict specifies properties for the column.
    Some keys in each col have special meaning:-
    
    <h4>label</h4>
    If the label key exists and thead is undefined then a thead is created using the labels as column headings

    <h4>class</h4>
    Specifies the css class attribute of the col element.<br>
    The col class may be used to format the column cells.If a feature is not available through CSS then cell contents may be formatted.<br>
    E.g. money is used to call format_money<br>
    Defined for money,number,integer,bool

    <h4>width</h4>
    The will set the width in the style attribute for the col element.

    <h4>format</h4>
    Use the function specified to format all the cells in that column including the tfoot cells.

    <h4>thClass</h4>
    Used to specify the class to apply to the corresponding th element in thead
    
    <h4>tfoot</h4>
    Specifies the value to use in the tfoot cell for that column
    </div>
    
    <h3>thead</h3>
    <div class="indent">
    A list of lists that is used to populate the thead
    </div>

    <h3>tbody</h3>
    <div class="indent">
    A list of lists that is used to populate the tbody
    </div>

    <h3>tfoot</h3>
    <div class="indent">
    A list of lists that is used to populate the tfoot
    </div>

    <h3>table</h3>
    <div class="indent">
    A <proc>table</proc> used to create the table.<br>
    If no column labels are specified then use the column keys.<br>
    Map the data in the table to the tbody using the column names.
    </div>

    <h3>qry</h3>
    <div class="indent">
    A sql query that is used to create the table.<br>
    The column names become column labels and the query results are shown in the tbody.
    </div>

    <h3>rowClasses</h3>
    <div class="indent">
    A list of css class names that will be repeatedly applied to tbody rows.
    </div>

    <h3>scrollHeight</h3>
    <div class="indent">
    Controls the height of the view port used to scroll the table with fixed headers.
    </div>

        <h3>headerRowClasses</h3>
        <div class="indent">
        A list of css class names that will be repeatedly applied to thead rows.
        </div>

Examples
--------
```tcl

% set tbody {
    {"Jimmy Tarbuck" 23.56}
    {"Des O'Conner"  15.632}
    {"Bob Monkhouse" 56.1}
}
% html_table tbody $tbody
<table>
<tbody>
<tr>
<td>Jimmy Tarbuck</td>
<td>23.56</td>
</tr>
<tr>
<td>Des O'Conner</td>
<td>15.632</td>
</tr>
<tr>
<td>Bob Monkhouse</td>
<td>56.1</td>
</tr>
</tbody>
</table>

% set cols {
    {label Name width 200}
    {label Balance width 100 class money}
}
% html_table cols $cols tbody $tbody
or
% html_table ~ cols tbody
<table>
<colgroup>
<col style="width:200">
<col class="money" style="width:100">
</colgroup>
<thead>
<tr>
<th>Name</th>
<th>Balance</th>
</tr>
</thead>
<tbody>
<tr>
<td>Jimmy Tarbuck</td>
<td>23.56</td>
</tr>
<tr>
<td>Des O'Conner</td>
<td>15.63</td>
</tr>
<tr>
<td>Bob Monkhouse</td>
<td>56.10</td>
</tr>
</tbody>
</table>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"