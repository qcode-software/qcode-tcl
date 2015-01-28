Validating User Input
=====================

part of [Qcode Documentation](index.md)

* * *

User input can be validated against the data model with very little setup using [filters] and [registration].

If [`qc::filter_validate`] is set up on Naviserver and request handlers are registered then validation will occur for any input on a registered handler. This means that arguments to a request handler will have been validated against the data model before the handler is called and therefore the developer need not worry about checking the data types of arguments.

In order to validate arguments for a request handler they must be present as the name of a column in the data model because the data type of the column is used to validate against. For example, if a request handler had an argument `post_id` then validation would look to the data model to obtain the data type of a column with the name `post_id`. If no such column exists then an error is thrown.

Once the data type is obtained from the data model it is checked using [`qc::is`] and [`qc::castable`]. See [Data Types: is, cast, castable] for more information on these ensembles.

As items are validated the record object of the [global JSON response] is set up with the results of validation for each item.

Should any item turn out to be invalid then the JSON response is returned to the client to let them know what was wrong. See [`qc::filter_validate`] for more information on the validation process.


### Custom & Manual Validation

There are occurrences where it may not be possible to validate some information accurately enough against the data model. Therefore there is the opportunity to manually validate input using [validation handlers].


* * *

Qcode Software Limited <http://www.qcode.co.uk>

[filters]: filters.md
[registration]: registration.md
[validation handlers]: registration.md
[Data Types: is, cast, castable]: data-types.md
[global JSON response]: global-json-response.md
[`qc::filter_validate`]: filters.md
[`qc::is`]: is.md
[`qc::castable`]: castable.md