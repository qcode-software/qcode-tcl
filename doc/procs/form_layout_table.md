qc::form_layout_table
=====================

part of [Docs](.)

Usage
-----
`qc::form_layout_table args`

Description
-----------
Construct an html table with 2 columns for labels and form elements

Examples
--------
```tcl

    % set conf {
        {name firstname value {} label Firstname width 200}
        {name surname value {} label Surname width 250}
        {name email value {} label Email id email_address}
        {name color value "" label Colour type select options {1 Red 2 Blue 3 Green}}
        {name agree value no type checkbox label Agree}
    }
    % qc::form_layout_table $conf
<table class="form-layout-table">
<colgroup>
<col class="label">
<col>
</colgroup>
<tbody>
<tr>
<td><label for="firstname">Firstname</label></td>
<td><input style="width:200px" id="firstname" name="firstname" value="" type="text" sticky="no"></td>
</tr>
<tr>
<td><label for="surname">Surname</label></td>
<td><input style="width:250px" id="surname" name="surname" value="" type="text" sticky="no"></td>
</tr>
<tr>
<td><label for="email_address">Email</label></td>
<td><input style="width:160px" name="email" value="" id="email_address" type="text" sticky="no"></td>
</tr>
<tr>
<td><label for="color">Colour</label></td>
<td><select id="color" name="color" sticky="no">
<option value="Red">1</option>
<option value="Blue">2</option>
<option value="Green">3</option>
</select>
</td>
</tr>
<tr>
<td></td>
<td><input id="agree" name="agree" value="no" type="checkbox" sticky="no"> <label for="agree">Agree</label></td>
</tr>
</tbody>
</table>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"