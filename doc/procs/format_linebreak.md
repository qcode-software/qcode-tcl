qc::format_linebreak
====================

part of [Docs](.)

Usage
-----
`qc::format_linebreak string width`

Description
-----------
Split $string into a list of lines without exceeding $width<br/>Avoid splitting words

Examples
--------
```tcl

% set string {Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.}
% 
% format_linebreak $string 80
{Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor } {incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis } {nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. } {Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu } {fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in } {culpa qui officia deserunt mollit anim id est laborum.}
%
%  join [format_linebreak $string 80] \n
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis 
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu 
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in 
culpa qui officia deserunt mollit anim id est laborum.
%

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"