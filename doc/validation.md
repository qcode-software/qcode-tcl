Validating User Input
=====================

part of [Qcode Documentation](index.md)

* * *

There are many different commands provided that will allow data to be checked against a certain type and can be found in [Data Types: is, cast, castable]. 

Against The Model
-----------------

The qcode-tcl library provides a method of validating user input against the data model using [`qc::validate2model`].

[`qc::validate2model`] accepts a dictionary as input. This dictionary should contain `name value` pairs where the `name` is the name of column in the data model (this can be fully qualified if necessary i.e. table.column) and the `value` is the value to be validated.

As well as determining if the input matches the data types in the model, [`qc::validate2model`] will also check if the input meets the constraints for that column in the model e.g. not null, above/below/is a certain value etc.

[`qc::validate2model`] will also set up the record object of the [connection response] with the results of validation for each item that was checked. As part of the record a message is grabbed from the data model to describe the problem if validation fails.

If the record type is `password` or `card_number` then it is automatically marked as sensitive and the value will not appear in the response.

### Dependencies

Since [`qc::validate2model`] takes a message from the data model to add to the record object of the [connection response] a table named `validation_messages` with columns `table_name`, `column_name`, and `message` must exist in the model and contain a row for each column that could possibly be validated against.

### Examples

```tcl
% qc::validate2model {firstname "Foo"}
true

# firstname as a column might be ambiguous because it could appear in other tables but with different types
# and constraints therefore it can be fully qualified with the table name to eliminate such ambiguity.
% qc::validate2model {users.firstname "Foo"}
true

% qc::validate2model {users.user_id "Foo" users.firstname "Foo"}
false

% qc::validate2model {foo "Foo"}
"foo" doesn't exist as a column in the database.
```

Using Registration & `qc::filter_validate`
------------------------------------------

User input can be validated against the data model with very little setup using [filters] and [registration].

If [`qc::filter_validate`] is set up on Naviserver and request handlers are registered then validation will occur for any input on a registered handler. This means that arguments to a request handler will have been validated against the data model before the handler is called therefore the developer need not worry about checking the arguments.

In order to validate arguments for a request handler they must be present as the name of a column in the data model. For example, if a request handler had an argument `post_id` then validation would look to the data model for a column with the name `post_id`. If no such column exists then an error is thrown. As noted in the examples above for `qc::validate2model` the column may be fully qualified with the table name to eliminate ambiguity.

Should any item turn out to be invalid then the connection response is returned to the client to let them know what was wrong. See [`qc::filter_validate`] for more information on the validation process.

### Differing Constraints & Arguments Not Present in the Data Model

There may be arguments for a request handler that are not present in your data model or that require different constraints from those already present in the data model.

Consider a request handler for viewing a sales report. Such a report might have many filters e.g. dates, customers, and products. However, many of these filters may not be present in your data model so how can they be validated?

Our solution is to add columns with appropriate types and constraints to tables called "required", "optional", and "form".

```sql
alter table required
add column from_date date not null,
add column to_date date not null;

alter table optional
add column products plain_text,
add column customers plain_test;
```

```tcl
register GET /reports/sales/by-category {
   required.from_date
   required.to_date
   {optional.products ""}
   {optional.customers ""}
} {
   ...
}
```

All columns that we've added to the table "required" have not null constraints while those added to the table "optional" are nullable. We found that this was the best way to deal with different requirements for arguments with the same names across different request handlers.

The table "form" exists to capture different constraints on arguments where the columns may already exist in other tables. For example, you may wish to constrain `from_date` on some sales reports to no earlier than 1 year ago but still allow other reports to filter earlier than this.

```sql
alter table form
add column from_date date not null,
add check (from_date >= current_date - '1 year'::interval);
```

```tcl
register GET /reports/sales {
   form.from_date
   required.to_date
} {
   ...
}
```

### Custom & Manual Validation

There are occurrences where it may not be possible to validate some information accurately enough against the data model. Therefore there is the opportunity to manually validate input using [validation handlers].


* * *

Qcode Software Limited <http://www.qcode.co.uk>

[filters]: filters.md
[registration]: registration.md
[validation handlers]: registration.md
[Data Types: is, cast, castable]: data-types.md
[connection response]: connection-response.md
[`qc::filter_validate`]: filters.md
[`qc::is`]: is.md
[`qc::castable`]: castable.md
[`qc::validate2model`]: procs/validate2model.md
