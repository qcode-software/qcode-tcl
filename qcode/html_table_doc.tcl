package provide qcode 2.01
package require doc
namespace eval qc {
    namespace export html_table_doc
}

proc qc::html_table_doc {args} {
    #| Create a 2 row table with labels on the first row and values on the 2nd row.
    # Requires a cols object
    set varNames [qc::args2vars $args]
    default tbody {}
    # data is pulled from caller's namespace
    set row {}
    foreach col $cols {
	qc::upcopy 1 [dict get $col name] value
	default value ""
	lappend row $value
    }
    lappend tbody $row
    lappend varNames cols tbody
    return [qc::html_table [dict_from {*}$varNames]]
}

doc qc::html_table_doc {
    Examples {
	% set cols {
	    {label "Sales Quote No." name sales_quote_no}
	    {label "Customer Order No." name customer_order_no}
	}
	% set sales_quote_no 12343
	% set customer_order_no Tel/Bill
	% qc::html_table_doc cols $cols class document
	<table class="document">
	<colgroup>
	<col name="sales_quote_no">
	<col name="customer_order_no">
	</colgroup>
	<thead>
	<tr>
	<th>Sales Quote No.</th>
	<th>Customer Order No.</th>
	</tr>
	</thead>
	<tbody>
	<tr>
	<td>12343</td>
	<td>Tel/Bill</td>
	</tr>
	</tbody>
	</table>
    }
}

