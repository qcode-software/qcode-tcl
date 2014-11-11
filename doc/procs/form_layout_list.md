qc::form_layout_list
====================

part of [Docs](.)

Usage
-----
`qc::form_layout_list conf`

Description
-----------
Layout the form elements in the conf with input elements below labels.

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
    % qc::form_layout_list $conf
<div style="padding-bottom:1em;"><label for="firstname">Firstname</label><br><input style="width:200px" id="firstname" name="firstname" value="" type="text"></div><div style="padding-bottom:1em;"><label for="surname">Surname</label><br><input style="width:250px" id="surname" name="surname" value="" type="text"></div><div style="padding-bottom:1em;"><label for="email_address">Email</label><br><input style="width:160px" name="email" value="" id="email_address" type="text"></div><div style="padding-bottom:1em;"><label for="color">Colour</label><br><select id="color" name="color">
<option value="Red">1</option>
<option value="Blue">2</option>
<option value="Green">3</option>
</select>
</div><div style="padding-bottom:1em;"><input id="agree" name="agree" value="no" type="checkbox"> <label for="agree">Agree</label></div>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"