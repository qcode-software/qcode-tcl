# Tcl pull request review

Apply these checks to changed Tcl files selected by this repository's lint workflow.
Use the repository's configured file patterns, Tcl source directory, test directory,
limits, and enabled checks. Honour any overrides in the workflow that calls
`qcode-ci.yml`. The defaults below apply when the caller does not override them.

## Checks

1. **Line length.** Flag lines longer than 100 characters. Count indentation and
   trailing whitespace. Count each tab as one character.
2. **File length.** Flag files longer than 400 lines. Count the whole file, including
   blank lines. For compatibility with Qcode CI, a trailing newline contributes
   an empty final line to the count. An empty file has zero lines.
3. **Procedure body length.** Flag procedure bodies longer than 80 lines. Count the
   body without the declaration or outer braces, trim whitespace at its edges, and
   count each SQL query recognised by the linter as one line.
4. **Procedure names.** Under the configured Tcl source directory (default `tcl/`),
   check that the unqualified procedure name starts with the filename stem and
   that its namespace matches the relative directory. For example,
   `tcl/orders/dispatch.tcl` can define `orders::dispatch_send`.
5. **Unit test presence.** Find at least one matching Tcltest definition in the
   configured test directory (default `test/`). Look recursively in `*.test`
   files for the exact declared procedure name, including any namespace, followed
   by a numeric suffix such as `-1` or `-1.0`.
6. **Procedure comments.** Check that each procedure body contains a documentation
   comment beginning with `#|`. Put the comment at the top of the body when
   suggesting a fix.

## Reporting findings

Use the full changed file for file and procedure counts and the repository's test
files for test matching. Report only violations you can verify. Leave an inline
comment on the changed line or nearest relevant changed line. Include the observed
count and configured limit for length findings, and suggest a specific fix when
possible. Group repeated findings where one fix addresses them.
